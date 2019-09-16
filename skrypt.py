#!/usr/bin/env python3
import json
import socket

def Ip_list():
	ip_list = ""
	
	# Loop to read data in .json file
	for ip in obj['tickets']:
		tmp_str = ip['src_ip'] # passing object source ip to temp string
		ip_list = ip_list + "," + tmp_str # adding source ip to whole ip list
	split_ip = ip_list.split(",") # split whole ip list 

	return split_ip
	
# Function which find most common source IP adress
def Task1():
	split_ip = Ip_list()
	max = 0
	ip_max = ""
	i = 0
	
	# Loop to find most common source IP
	while i < len(split_ip):
		ip_tmp = split_ip[i] # passing ip to temp string
		ip_count = split_ip.count(ip_tmp) # Count how many times we can find IP in whole list
		# Checking if we find most common source IP in this loop iteration
		if ip_count > max: 
			max = ip_count
			ip_max = split_ip[i]
		i += 1
	return ip_max
	
def Task2(ip_adress):
	max = 0
	src_ip_split = Ip_list()
	ip_count = src_ip_split.count(ip_adress)
	
	for ip in src_ip_split:
		if ip['src_ip'] == ip_adress:
			tmp_str = ip['dst_ip']
			ip_list = ip_list + "," + tmp_str
		dst_ip_split = ip_list.split(",")
		set_dst_ip_split = list(set(dst_ip_split))
		max = len(set_dst_ip_split)
		return max
	
with open('incidents.json', 'r') as json_file:
	incidents = json_file.read()
	
	obj = json.loads(incidents)
	
# Connection to server
try: 
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.connect(("2018shell.picoctf.com", 14079)) 
except Exception:
	print("Connection failed")
	
while True:
	text = s.recv(4096).decode("utf-8")
	print(text)
	
	
	if "of the most common ones" in text:
		anserw_1 = Task1()
		anserw_1 += "\n"
		print(anserw_1)
		s.send(anserw_1.encode("utf-8"))
		
	if "How many unique destination IP addresses were targeted by the source IP address " in text:
		ip_adress = text[-17:-2]
		print(ip_adress)
		anserw_2 = Task2(ip_adress)
		s.send(count.encode("utf-8"))
	