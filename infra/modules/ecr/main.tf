resource "aws_ecr_repository" "this" {
  name                 = "${var.name_prefix}-repo-${var.name}"
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = { Name = "${var.name_prefix}-repo-${var.name}" }
}

# タグなしイメージ（新しいイメージのpushで上書きされた古いイメージ）を一定数までに抑える
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images"
        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = var.untagged_image_count_limit
        }
        action = { type = "expire" }
      }
    ]
  })
}
