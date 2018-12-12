package main

import "net/http"

type Route struct {
	Name        string
	Method      string
	Pattern     string
	HandlerFunc http.HandlerFunc
}

type Routes []Route

var routes = Routes{
	Route{
		"Index",
		"GET",
		"/",
		Index,
	},
	Route{
		"JoinData",
		"GET",
		"/joindata/{num}",
		TodoIndex,
	},
	Route{
		"ToolData",
		"POST",
		"/tooldata",
		TodoCreate,
	},
	Route{
		"MasterBoard",
		"POST",
		"/masterboard",
		TodoShow,
	},
	Route{
		"Cartesian",
		"POST",
		"/position",
		TodoShow,
	},
	Route{
		"Configuration",
		"POST",
		"/configuration",
		TodoShow,
	},
	Route{
		"Getter",
		"GET",
		"/get/{pkg_num}",
		getInfo,
	},
	Route{
		"ShowLog",
		"GET",
		"/log",
		getLog,
	},
}
