#!/bin/bash
set -x

users=()
<% users=p('ssh.users') %>
<% if users != "none" && users.length > 0 then %>
<% users.each do |user| %>
users=("${users[@]}" "<%= user['name'] %>")
<% end %>
<% end %>


function create_user() {
	echo "Try to create users."
<% if users != "none" && users.length > 0 then %>
		local user_name=""
		local user_password=""
		local account_expiry_date=""
		local password_age=""
		<% users.each do |user| %>
		user_name=<%= user["name"] %>
		user_password=<%= user["password"] %>
		account_expiry_date=<%= user["account_expiry_date"] %>
		password_age=<%= user["password_age"] %>
		if [ ! -d /home/${user_name} ]; then
			useradd -G vcap -m $user_name
			echo "$user_name:$user_password" | chpasswd
		fi
		chage -m 0 -M ${password_age} -E ${account_expiry_date} ${user_name}
		<% end %>
<% end %>
}

function start() {
	echo "start to init ssh."
	service ssh stop
	if [ ! -d /root/.ssh ]; then
		mkdir -p /root/.ssh
	fi
	cp /var/vcap/jobs/ssh/conf/id_rsa /root/.ssh/
	cp /var/vcap/jobs/ssh/conf/id_rsa.pub /root/.ssh/
	cp /var/vcap/jobs/ssh/conf/authorized_keys /root/.ssh/
	chmod 400 /root/.ssh/*
<% if users != "none" && users.length > 0 then %>
		for user_name in "${users[@]}"
		do
			if [ ! -d /home/$user_name/.ssh ]; then
				mkdir -p /home/$user_name/.ssh
			fi
			cp /var/vcap/jobs/ssh/conf/id_rsa /home/$user_name/.ssh/
			cp /var/vcap/jobs/ssh/conf/id_rsa.pub /home/$user_name/.ssh/
			cp /var/vcap/jobs/ssh/conf/authorized_keys /home/$user_name/.ssh/
			chown -R $user_name:$user_name /home/$user_name/.ssh
			chmod 400 /home/$user_name/.ssh/*
		done
<% end %>
	cp /var/vcap/jobs/ssh/conf/ssh_config /etc/ssh/ssh_config
	cp /var/vcap/jobs/ssh/conf/sshd_config /etc/ssh/sshd_config
	service ssh start
}

function stop() {
	rm -rf /root/.ssh
<% if users != "none" && users.length > 0 then %>
	for user_name in "${users[@]}"
	do
		rm -rf /home/${user_name}/.ssh
	done
<% end %>
}

case "$1" in
	'start')
	  create_user
	  start
	;;
	'stop')
	  stop
	;;
esac
