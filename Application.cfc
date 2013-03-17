<cfcomponent>
  <cfset this.name = "cfadmin">
	<cfset this.sessionmanagement = true>
	
	<cfset variables.appKey = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX">
	<cfset variables.iKey = "DIS6Y7DWNN86EWO1HRDQ">
	<cfset variables.sKey = "xXjjgRtKvzZoXW23dJkfPecC43dkStyQFyLezuqS">
	<cfset variables.duoHost = "api-a4f60ecc.duosecurity.com">
	
	
	<cffunction name="OnRequest">
		<cfargument name="template">
		<cfinclude template="Application.cfm">
		<cfset var local = StructNew()>
		<cfif arguments.template contains "logout.cfm" AND isAuthenticatedTwoFactor()>
			<cfset StructDelete(session, "duoAuthenticated")>
			<cfinclude template="#arguments.template#">
			<cfreturn>
		</cfif>
		<cfif StructKeyExists(form, "sig_response")>
			<cfset local.duo_user = CreateObject("component", "duo_coldfusion.DuoWeb").verifyResponse(iKey=variables.iKey, aKey = variables.appKey, sKey=variables.sKey, sig_response=form.sig_response)>
			<cfif local.duo_user IS "pete">
				<cfset session.duoAuthenticated = true>
			</cfif>
		</cfif>
		<cfif IsUserLoggedIn() AND NOT isAuthenticatedTwoFactor()>
			<cfset local.post_action = "/CFIDE/administrator/index.cfm">
			<cfset session.duo_sig_request = CreateObject("component", "duo_coldfusion.DuoWeb").signRequest(iKey=variables.iKey, aKey = variables.appKey, sKey=variables.sKey, username=GetAuthUser())>
			<!--- show second factor authenication page --->
			<!doctype html>
			<html>
				<head>
					<title>Please Authenticate</title>
					<script src="/duo_coldfusion/js/Duo-Web-v1.bundled.min.js"></script>
					<cfoutput>
					<script>
					  Duo.init({
					    'host': '#JSStringFormat(variables.duoHost)#',
					    'sig_request': '#JSStringFormat(session.duo_sig_request)#',
					    'post_action': ''
					  });
					</script>
					</cfoutput>
				</head>
				<body>
					<h2>Authenticate</h2>
					<iframe id="duo_iframe" width="100%" height="500" frameborder="0"></iframe>
				</body>
			</html>
		<cfelse>
			<!--- two factor authentication --->
			<cfinclude template="#arguments.template#">	
		</cfif>
		
	</cffunction>
	
	<cffunction name="isAuthenticatedTwoFactor" returntype="boolean">
		<cfreturn StructKeyExists(session, "duoAuthenticated") AND session.duoAuthenticated>
	</cffunction>

</cfcomponent>
