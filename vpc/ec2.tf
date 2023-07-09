
# iam role for ec2 instance profile
resource "aws_iam_role" "tetora_ec2_role" {
  name               = "tetora_ec2_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tetora_ec2_role_policy_attachment" {
  role       = aws_iam_role.tetora_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "tetora_ec2_profile" {
  name = "tetora_ec2_profile"
  role = aws_iam_role.tetora_ec2_role.name
}



resource "aws_instance" "app_server" {
  subnet_id            = aws_subnet.tetora_private_1a.id
  ami                  = var.ami_id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.tetora_ec2_profile.name
  tags = {
    Name = var.instance_name
  }
}
