locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    # タスクロールを作成するときはロールに関連付けられた信頼関係ポリシーで
    # aws:SourceAccount または aws:SourceArn のいずれかの条件キーを使用してアクセス許可のスコープを明確にし、
    # 混乱した代理のセキュリティ問題の発生を防止することが推奨されている
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.aws_account_id]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.name_prefix}-role-backend-task-execution"
  assume_role_policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# コンテナ定義のsecretsで参照するSSMパラメータの取得権限
#
# Note: AWS管理キー（alias/aws/ssm）で暗号化したSecureStringの場合、
# kms:Decryptを明示的に許可する必要はない（カスタマー管理キーを使う場合は必要）。
data "aws_iam_policy_document" "read_ssm_parameters" {
  count = length(var.ssm_parameter_arns) > 0 ? 1 : 0

  statement {
    sid       = "GetParameters"
    actions   = ["ssm:GetParameters"]
    resources = var.ssm_parameter_arns
  }
}

resource "aws_iam_role_policy" "read_ssm_parameters" {
  count = length(var.ssm_parameter_arns) > 0 ? 1 : 0

  name   = "read-ssm-parameters"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.read_ssm_parameters[0].json
}
