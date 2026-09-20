resource "aws_iam_instance_profile" "ghost_server" {
  name = "ghost_server_profile"
  role = aws_iam_role.ghost_server.name
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "ghost_server" {
  name               = "ghost_server"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
  role       = aws_iam_role.ghost_server.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
