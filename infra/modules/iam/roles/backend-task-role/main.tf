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
  name               = "${var.name_prefix}-role-backend-task"
  assume_role_policy = data.aws_iam_policy_document.this.json
}
