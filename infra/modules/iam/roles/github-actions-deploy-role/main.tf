locals {
  oidc_provider_domain = "token.actions.githubusercontent.com"
}

# GitHub ActionsからOIDCでAssumeされる信頼関係ポリシー
#
# aud（sts.amazonaws.com）とsub（リポジトリ・ref）の両方を条件に指定して、
# 他のリポジトリ・他のブランチのワークフローからAssumeできないようにする。
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_domain}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${local.oidc_provider_domain}:sub"
      values   = var.allowed_subjects
    }
  }
}

resource "aws_iam_role" "this" {
  name                 = "${var.name_prefix}-role-github-actions-deploy"
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  max_session_duration = var.max_session_duration
}

data "aws_iam_policy_document" "deploy" {
  # ECRへのログイン（docker login）に必要。リソースレベルの権限指定に対応していないため"*"を指定する
  statement {
    sid       = "GetAuthorizationToken"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  # ビルドしたイメージのpush（と差分レイヤー判定のためのpull）
  statement {
    sid = "PushImageToEcr"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = var.ecr_repository_arns
  }

  # タスク定義の新リビジョン登録。これらのAPIはリソースレベルの権限指定に対応していないため"*"を指定する
  statement {
    sid = "RegisterTaskDefinition"
    actions = [
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
    ]
    resources = ["*"]
  }

  # ECSサービスの更新とデプロイ完了待ち
  statement {
    sid = "DeployEcsService"
    actions = [
      "ecs:DescribeServices",
      "ecs:UpdateService",
    ]
    resources = var.ecs_service_arns
  }

  # タスク定義に指定するタスクロール・タスク実行ロールをECSに渡す権限。
  # 渡し先のサービスをecs-tasks.amazonaws.comに限定して、任意のサービスへのPassRoleを防ぐ
  statement {
    sid       = "PassEcsTaskRoles"
    actions   = ["iam:PassRole"]
    resources = var.pass_role_arns

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "deploy" {
  name   = "deploy"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.deploy.json
}
