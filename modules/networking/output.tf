output "vpc_id" {
    value = aws_vpc.vpc.id
  
}

output "pub_subA_id" {
    value = aws_subnet.public_subnetA.id
  
}

output "pub_subB_id" {
    value = aws_subnet.public_subnetB.id
  
}

output "priv_subA_id" {
    value = aws_subnet.private_subnetA.id
  
}

output "priv_subB_id" {
    value = aws_subnet.private_subnetB.id
  
}

output "pvt_subnetA" {
    value = aws_subnet.private_subnetA
}

output "pvt_subnetB" {
    value = aws_subnet.private_subnetB
}