class SignInController < ApplicationController


	def login

	end

	def after_login		
		if params[:email] == "single_role_user@gmail.com"
			cookies[:login] = JSON.generate({ uid: 4132 , roles: [], email: "single_role_user@gmail.com", ORI: "CA0349435" })
			redirect_to single_role_stops_path(cookies: cookies[:login])
		elsif params[:email] == "multiple_roles_user@gmail.com"
			cookies[:login] = JSON.generate({ uid: 2134 , roles: ["LEA Officer", "LEA Proxy", "LEA Reviewer"], email: "multiple_roles_user@gmail.com", ORI: "CA2449437" })
			redirect_to multiple_role_stops_path(cookies: cookies[:login])
		end	
	end


	
end
