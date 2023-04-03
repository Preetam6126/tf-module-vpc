resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = merge(
  var.tags,
  { Name = "${var.env}-vpc" }
  ) 
}

## Pubic Route Table
   
 resource "aws_route_table" "public_route_talbe" {
  vpc_id = aws_vpc.main.id
  
  for_each = var.public_subnets
  tags = merge(
  var.tags,
  { Name = "${var.env}-${each.value["name"]}" }
   )
}
  
## Public Subnets

resource "aws_subnet" "public_subnets" {
  
   vpc_id = aws_vpc.main.id
  
   for_each          = var.public_subnets
   cidr_block        = each.value["cidr_block"]
   availability_zone = each.value["availability_zone"]
   tags = merge(
   var.tags,
  { Name = "${var.env}-${each.value["name"]}" }
   ) 
 }
 
## Public Route Table Association

resource "aws_route_table_association" "public_assocition" {
  for_each       = var.public_subnets
  # subnet_id      = aws_subnet.public_subnets[each.value["name"]].id
  ##the above function is right but we can also use lookup as below
  subnet_id      = lookup(lookup(aws_subnet.public_subnets, each.value["name"],null), "id", null)
  
  route_table_id = aws_route_table.public_route_talbe[each.value["name"]].id
}
 
## Private Route Table
   
 resource "aws_route_table" "private_route_talbe" {
  vpc_id = aws_vpc.main.id
  
  for_each = var.private_subnets
  tags = merge(
  var.tags,
  { Name = "${var.env}-${each.value["name"]}" }
   )
}

## Public Route Table Association

resource "aws_route_table_association" "private_assocition" {
  for_each       = var.private_subnets
  subnet_id      = lookup(lookup(aws_subnet.private_subnets, each.value["name"],null), "id", null)
  route_table_id = aws_route_table.private_route_talbe[each.value["name"]].id
}
 
## Private Subnets

resource "aws_subnet" "private_subnets" {
  
  vpc_id = aws_vpc.main.id
  tags = merge(
  var.tags,
  { Name = "${var.env}-${each.value["name"]}" }
   ) 
   
   for_each          = var.private_subnets
   cidr_block        = each.value["cidr_block"]
   availability_zone = each.value["availability_zone"]
   
}
   
