#!/sbin/openrc-run

name=runtime
description="Velocity NodeJS runtime"
supervisor="supervise-daemon"
command="node /runtime/index.js"
pidfile="/run/runtime.pid"
command_user="root:root"

depend() {
	after net
}