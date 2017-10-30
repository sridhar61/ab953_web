require 'cassandra'
require "json"
class StopsController < ApplicationController
  include HTTParty
  include StopsHelper
  before_filter :set_keyspace

  add_breadcrumb "home", :stops_path

  private

  def set_keyspace
    #raise "Hello".inspect
    cluster = Cassandra.cluster
    cluster.each_host do |host| # automatically discovers all peers
      puts "Host #{host.ip}: id=#{host.id} datacenter=#{host.datacenter} rack=#{host.rack}"
    end
    keyspace = 'sdcs'
    @session  = cluster.connect(keyspace)
  end


  public

  def index
    #@basis_search_options = Constant.get_all_constants
    #add_breadcrumb "", stops_path
  end

  def stop_date_entry
    add_breadcrumb "Stop Data", stop_date_entry_stops_path
  end

  def initial_stop
    #raise @session.inspect
    #raise Time.now.to_i.inspect
    #raise params.inspect
    #raise @queue.inspect
    #Resque::Job.create(select_queue(params), self, 5)
    if true
      #stop_data = session.execute("
      count_records = @session.execute("select count(*) from stopdata_by_doj_record_id where agency_ori= 'CA9876432'  ALLOW FILTERING;");
      total_records = count_records.rows.first["count"]
      date_of_stop = date_format(params["date_of_stop"])
      doj_record_id = doj_record_id(params["date_of_stop"], total_records)
      time_of_stop = params["time_of_stop"]+":00.000"
      agency_ori = "CA9876432"
      stop_data = @session.execute("INSERT INTO stopdata_by_doj_record_id (doj_record_id, agency_ori, dateofstop ,
      starttimeofstop ,durationofstop, officer, createtime) values  ( '#{doj_record_id}',
      '#{agency_ori}', '#{date_of_stop}' ,'#{time_of_stop}',#{params["duration_of_stop"].to_i},
      {officer_uid: '01', proxylogin: '09', officeryearsofexperience: #{params["experience"].to_i},
      officertypeofassignment: #{params["assignment_type"].to_i},
      officerotherassignmenttype: '#{params["other_assingment_type"]}' },
      '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}');")
      #count = session.execute(
      #stop_data = @session.execute("INSERT INTO stopdata_by_doj_record_id (doj_record_id, agency_ori, dateofstop ,starttimeofstop ,durationofstop, officer, createtime) values  ( '#{doj_record_id}', '#{agency_ori}', '#{date_of_stop}','#{time_of_stop}',#{params["duration_of_stop"]},{ officerotherassignmenttype: '#{params["other_assingment_type"]}', officer_uid: '01', proxylogin: '09', officeryearsofexperience: #{params["experience"].to_i}, officertypeofassignment: #{params["assignment_type"].to_i
      #}, '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}');")

      session[:doj_record_id] = doj_record_id

      #@doj_record_id = @session.execute("select doj_record_id from ")
      #session.execute(stop_data)
      #raise stop_data.inspect
      #Resque.enqueue(SleeperWorker, 5)
=begin
      respond_to do |format|
        format.html { redirect_to stop_type_stops_path, notice: 'Snippet was successfully destroyed.' }
        format.json { head :no_content }
      end
=end
    else
    end
  end

  def stop_type

  end

  def download_pdf
    #to send a file
    send_file "#{Rails.root}/app/assets/docs/Физика.pdf", type: "application/pdf", x_sendfile: true
  end

  def single_role
    #@cookies = params[:cookies]
    #@parsed_cookie = JSON.parse(@cookies)
  end


  def multiple_role
    #@cookies = params[:cookies]
    #@parsed_cookie = JSON.parse(@cookies)
  end

  def stop_type_submit
    call = '/data_validation.json'
    url =   HTTParty.get("http://192.168.167.162:3001#{call}",
      :headers => {'ContentType' => 'application/json'})
    response = url.parsed_response

  end

  def person_details
    #raise params.inspect
    #call = '/data_validation.json'
    @perceived_disabilities = params["perceived_disability"].join(',')
    @person_is_student = params["person_is_student"] == "yes" ? true : false
    @perceived_lgbt = params["perceived_lgbt"] == "yes" ? true : false
    @gendernonconforming = params[:perceived_gender_non_confirming] == "yes" ? true : false
    @limitedenglish = params[:perceived_english_fluency]
    @perceived_race_gender = params[:perceived_race_gender].to_i
    @perceived_race_set = params[:perceived_race_set].join(',')
    #a = { "perceived_disabilities" => "123"}
    #raise a.inspect
    #b = { "perceived_disabilities" => @perceived_disabilities, "person_is_student" => params["person_is_student"],"perceived_lgbt" => params["perceived_lgbt"], "gendernonconforming" => @gendernonconforming}
    #raise b.inspect
    cookies["person_details"] = JSON.generate({ "perceived_disabilities" => @perceived_disabilities,
    "person_is_student" => params["person_is_student"],"perceived_lgbt" => params["perceived_lgbt"],
    "gendernonconforming" => @gendernonconforming, "age" => params["perceived_age"].to_i, "ethnicity" => @perceived_race_set,
    "gender" => @perceived_race_gender, "stopforastudent" => @person_is_student, "lgbt" => @perceived_lgbt, "limitedenglish" => @limitedenglish })
    c = JSON.parse(cookies["person_details"])
    #raise c.inspect
    #raise @perceived_disabilities.inspect
    #@perceived_disabilities
    #url =   HTTParty.get("http://192.168.167.162:3001#{call}",
     # :headers => {'ContentType' => 'application/json'})
    #response = url.parsed_response
    #actionstaken: , basisforpropertyseizure: , basisforsearch: , evidenceset: ,
    #, ethnicity: {}, gender: , gendernonconforming: , k12hyper: , lgbt: , limitedenglish: , stopforastudent: }, persondeleteothercomment: , persondeletereason: , personnum: , primaryreason: , resultofstop: , search: , typeofpropertyseized: }
    @doj_record_id = session[:doj_record_id]
    #raise "UPDATE stopdata_by_doj_record_id SET persondata= [{ perceptiondata: {k12hyper: 'yes', ethnicity: {'#{@perceived_race_set}'}, gender: {'#{@perceived_race_gender}',age: #{params["perceived_age"].to_i}, disabilities: '#{@perceived_disabilities}', stopforastudent: #{@person_is_student}, gendernonconforming: '#{@gendernonconforming}', lgbt: #{@perceived_lgbt}, limitedenglish: '#{@limitedenglish}' } }] WHERE doj_record_id= '#{@doj_record_id}';".inspect
    @session.execute("UPDATE stopdata_by_doj_record_id SET persondata= [{ perceptiondata: {k12hyper: 'yes',
    ethnicity: {'#{@perceived_race_set}'}, gender: '#{@perceived_race_gender}',age: #{params["perceived_age"].to_i},
    disability: {'#{@perceived_disabilities}'}, stopforastudent: #{@person_is_student},
    gendernonconforming: #{@gendernonconforming}, lgbt: #{@perceived_lgbt}, limitedenglish: '#{@limitedenglish}' } }]
    WHERE doj_record_id= '#{@doj_record_id}'; ")
    #@session.execute("UPDATE stopdata_by_doj_record_id SET (location) values ({locationdescription: '#{params["location_for_stop"]}', closestcity: '#{params["closest_city"]}'}) where doj_record_id= '#{@doj_record_id}'");
    #@session.execute("UPDATE stopdata_by_doj_record_id SET location={locationdescription: '#{params["location_for_stop"]}', closestcity: '#{params["closest_city"]}'} WHERE doj_record_id= '#{@doj_record_id}';")
  end

  def location
    @doj_record_id = session[:doj_record_id]
    #@session.execute("UPDATE stopdata_by_doj_record_id SET (location) values ({locationdescription: '#{params["location_for_stop"]}', closestcity: '#{params["closest_city"]}'}) where doj_record_id= '#{@doj_record_id}'");
    @session.execute("UPDATE stopdata_by_doj_record_id SET location={locationdescription: '#{params["location_for_stop"]}', closestcity: '#{params["closest_city"]}'} WHERE doj_record_id= '#{@doj_record_id}';")
  end

  def reason_for_stop
    person_details = JSON.parse(cookies["person_details"])
    @perceived_disabilities = person_details["perceived_disabilities"]
    @person_is_student = person_details["person_is_student"]
    @perceived_lgbt = person_details["perceived_lgbt"] == "yes" ? true : false
    @gendernonconforming = person_details["gendernonconforming"]
    @perceived_age = person_details["perceived_age"].to_i
    @ethnicity = person_details["ethnicity"]
    @gender = person_details["gender"]
    @stopforastudent = person_details["stopforastudent"] == "yes" ? true : false
    @lgbt = person_details["lgbt"]
    @limitedenglish = person_details["limitedenglish"]
    @perceived_race_set = person_details["ethnicity"]
    @perceived_race_gender = person_details["gender"]
    @age = person_details["age"]
    @doj_record_id = session[:doj_record_id]
    cookies["reason_for_stop"] = JSON.generate({ "resp_to_svc_call" => params["response_to_call_service"], "prireasonforstop" => params["select_reason_for_stop"],
    "reasonforstopnarrative" => params["reason_for_stop_explaination"], "suspicion_offense_cd" => params["suspicion_cjis_offense_code"], "trafficviolation" => params["type_of_traffic_violation"], "trafficviolationoffensecd" => params["violation_suspicion_cjis_offense_code"] })


    @session.execute("UPDATE stopdata_by_doj_record_id SET resp_to_svc_call ='#{params["response_to_call_service"]}', persondata= [{ perceptiondata: {k12hyper: 'yes', ethnicity: {'#{@perceived_race_set}'}, gender: '#{@perceived_race_gender}',age: #{@age}, disability: {'#{@perceived_disabilities}'}, stopforastudent: #{@stopforastudent}, gendernonconforming: #{@gendernonconforming}, lgbt: #{@perceived_lgbt}, limitedenglish: '#{@limitedenglish}' }, personnum: 34, primaryreason: {edu_cd_sect: 'yes', edu_cd_subdiv: '#{@perceived_race_set}', prireasonforstop: '#{params["select_reason_for_stop"]}', reasonforstopnarrative: '#{params["reason_for_stop_explaination"]}', st_casing: 'yes', st_drugtxn: 'yes', st_lookout: 'yes', st_matcheddesc: 'yes', st_officerwitnessed: 'yes', st_other: 'yes', st_suspiciousobjt: 'yes', st_violentcrime: 'yes', st_witnessid: 'yes', suspicion_offense_cd: '#{params["suspicion_cjis_offense_code"]}', trafficviolation: '#{params["type_of_traffic_violation"]}', traffic_violation_offense_cd: '#{params["violation_suspicion_cjis_offense_code"]}' } }] WHERE doj_record_id= '#{@doj_record_id}'; ")
  end


  def post_stop_action

  end

  def search

  end

  def action_taken
    reason_for_stop = JSON.parse(cookies["reason_for_stop"])
    person_details = JSON.parse(cookies["person_details"])
    @resp_to_svc_call = reason_for_stop["resp_to_svc_call"]
    @prireasonforstop = reason_for_stop["prireasonforstop"]
    @reasonforstopnarrative = reason_for_stop["reasonforstopnarrative"]
    @suspicion_offense_cd = reason_for_stop["suspicion_offense_cd"]
    @trafficviolation = reason_for_stop["trafficviolation"]
    @trafficviolationoffensecd = reason_for_stop["trafficviolationoffensecd"]
    @perceived_disabilities = person_details["perceived_disabilities"]
    @person_is_student = person_details["person_is_student"]
    @perceived_lgbt = person_details["perceived_lgbt"] == "yes" ? true : false
    @gendernonconforming = person_details["gendernonconforming"]
    @perceived_age = person_details["perceived_age"].to_i
    @ethnicity = person_details["ethnicity"]
    @perceived_race_gender = person_details["gender"]
    @stopforastudent = person_details["stopforastudent"] == "yes" ? true : false
    @lgbt = person_details["lgbt"]
    @limitedenglish = person_details["limitedenglish"]
    @perceived_race_set = person_details["ethnicity"]
    @resp_to_svc_call = reason_for_stop["resp_to_svc_call"]
    @doj_record_id = session[:doj_record_id]
    cookies["actions_taken"] = JSON.generate({ "batonused" => params["batonused"], "caninebit" => params["caninebit"], "canineused": params["canineused"], "cardetention": params["cardetention"], "cuffed": params["cuffed"], "curbsidedetention" => params["curbsidedetention"], "fieldsobrietytest" => params["fieldsobrietytest"],
    "firearmpointed" => params["firearmpointed"], "firearmused" => params["firearmused"], "k12admstatm" => params["k12adminstatm"], "maceused" => params["maceused"] , "actionsnone" => params["none"], "otherphysicalvehicle" => params["otherphysicalvehicle"], "photographed"=> params["photographed"], "removedbycontact"=> params["removedbycontact"],
    "removedbyorder" => params["removedbyorder"], "rubberbulletsused" => params["rubberbulletsused"], "stungunused": params["stungunused"]})
    @session.execute("UPDATE stopdata_by_doj_record_id SET resp_to_svc_call ='#{@resp_to_svc_call}', persondata= [{ perceptiondata: {k12hyper: 'yes', ethnicity: {'#{@perceived_race_set}'}, gender: '#{@perceived_race_gender}',age: #{@perceived_age}, disability: {'#{@perceived_disabilities}'}, stopforastudent: #{@stopforastudent}, gendernonconforming: #{@gendernonconforming}, lgbt: #{@perceived_lgbt}, limitedenglish: '#{@limitedenglish}' }, personnum: 34, primaryreason: {edu_cd_sect: 'yes', edu_cd_subdiv: '#{@perceived_race_set}', prireasonforstop: '#{@prireasonforstop}', reasonforstopnarrative: '#{@reasonforstopnarrative}', st_casing: 'yes', st_drugtxn: 'yes', st_lookout: 'yes', st_matcheddesc: 'yes', st_officerwitnessed: 'yes', st_other: 'yes', st_suspiciousobjt: 'yes', st_violentcrime: 'yes', st_witnessid: 'yes', suspicion_offense_cd: '#{@suspicion_offense_cd}', trafficviolation: '#{@trafficviolation}', traffic_violation_offense_cd: '#{@trafficviolationoffensecd}' }, actionstaken: {batonused: '#{params["batonused"]}', caninebit: '#{params["caninebit"]}', canineused: '#{params["canineused"]}', cardetention: '#{params["cardetention"]}', cuffed: '#{params["cuffed"]}', curbsidedetention: '#{params["curbsidedetention"]}', fieldsobrietytest: '#{params["fieldsobrietytest"]}', firearmpointed: '#{params["firearmpointed"]}', firearmused: '#{params["firearmused"]}', k12admstatm: '#{params["k12adminstatm"]}', maceused: '#{params["maceused"]}' , actionsnone: '#{params["none"]}', otherphysicalvehicle: '#{params["otherphysicalvehicle"]}', photographed: '#{params["photographed"]}', removedbycontact: '#{params["removedbycontact"]}',removedbyorder: '#{params["removedbyorder"]}', rubberbulletsused: '#{params["rubberbulletsused"]}', stungunused: '#{params["stungunused"]}' } } ] WHERE doj_record_id= '#{@doj_record_id}';")
  end

  def basis_for_search
    #raise params.inspect
    reason_for_stop = JSON.parse(cookies["reason_for_stop"])
    person_details = JSON.parse(cookies["person_details"])
    actions_taken = JSON.parse(cookies["actions_taken"])
    #raise person_details.inspect
    @resp_to_svc_call = reason_for_stop["resp_to_svc_call"]
    @prireasonforstop = reason_for_stop["prireasonforstop"]
    @reasonforstopnarrative = reason_for_stop["reasonforstopnarrative"]
    @suspicion_offense_cd = reason_for_stop["suspicion_offense_cd"]
    @trafficviolation = reason_for_stop["trafficviolation"]
    @trafficviolationoffensecd = reason_for_stop["trafficviolationoffensecd"]
    @perceived_disabilities = person_details["perceived_disabilities"]
    @person_is_student = person_details["person_is_student"]
    @perceived_lgbt = person_details["perceived_lgbt"] == "yes" ? true : false
    @gendernonconforming = person_details["gendernonconforming"]
    @perceived_age = person_details["perceived_age"].to_i
    @ethnicity = person_details["ethnicity"]
    @perceived_race_gender = person_details["gender"]
    @stopforastudent = person_details["stopforastudent"] == "yes" ? true : false
    @lgbt = person_details["lgbt"]
    @limitedenglish = person_details["limitedenglish"]
    @perceived_race_set = person_details["ethnicity"]
    @resp_to_svc_call = reason_for_stop["resp_to_svc_call"]
    @doj_record_id = session[:doj_record_id]
    cookies["basisforsearch"] = JSON.generate({ "basisforsearchnarrative" => params["basisforsearchnarrative"], "consentgiven"=> params["consentgiven"], "officersafety" => params["officersafety"], "searchwarrant" => params["searchwarrant"], "conditionofparole" => params["conditionofparole"], "suspectedweapon" => params["suspectedweapon"], "visiblecontraband" => params["visiblecontraband"],
     "odorofcontraband" => params["odorofcontraband"], "caninedetection" => params["caninedetection"], "evidenceofcrime" => params["evidenceofcrime"], "exigentcircumstances"=> params["exigentcircumstances"] })
    @session.execute("UPDATE stopdata_by_doj_record_id SET resp_to_svc_call ='#{@resp_to_svc_call}', persondata= [{ basisforsearch: {basisforsearchnarrative: '#{params["basisforsearchnarrative"]}', consentgiven: '#{params["consentgiven"]}', officersafety: '#{params["officersafety"]}', searchwarrant: '#{params["searchwarrant"]}', conditionofparole: '#{params["conditionofparole"]}', suspectedweapon: '#{params["suspectedweapon"]}', visiblecontraband: '#{params["visiblecontraband"]}', odorofcontraband: '#{params["odorofcontraband"]}', caninedetection: '#{params["caninedetection"]}', evidenceofcrime: '#{params["evidenceofcrime"]}', exigentcircumstances: '#{params["exigentcircumstances"]}' },  perceptiondata: {k12hyper: 'yes', ethnicity: {'#{@perceived_race_set}'}, gender: '#{@perceived_race_gender}',age: #{@perceived_age}, disability: {'#{@perceived_disabilities}'}, stopforastudent: #{@stopforastudent}, gendernonconforming: #{@gendernonconforming}, lgbt: #{@perceived_lgbt}, limitedenglish: '#{@limitedenglish}' }, personnum: 34, primaryreason: {edu_cd_sect: 'yes', edu_cd_subdiv: '#{@perceived_race_set}', prireasonforstop: '#{@prireasonforstop}', reasonforstopnarrative: '#{@reasonforstopnarrative}', st_casing: 'yes', st_drugtxn: 'yes', st_lookout: 'yes', st_matcheddesc: 'yes', st_officerwitnessed: 'yes', st_other: 'yes', st_suspiciousobjt: 'yes', st_violentcrime: 'yes', st_witnessid: 'yes', suspicion_offense_cd: '#{@suspicion_offense_cd}', trafficviolation: '#{@trafficviolation}', traffic_violation_offense_cd: '#{@trafficviolationoffensecd}' }, actionstaken: {batonused: '#{actions_taken["batonused"]}', caninebit: '#{actions_taken["caninebit"]}', canineused: '#{actions_taken["canineused"]}', cardetention: '#{actions_taken["cardetention"]}', cuffed: '#{actions_taken["cuffed"]}', curbsidedetention: '#{actions_taken["curbsidedetention"]}', fieldsobrietytest: '#{actions_taken["fieldsobrietytest"]}', firearmpointed: '#{actions_taken["firearmpointed"]}', firearmused: '#{actions_taken["firearmused"]}', k12admstatm: '#{actions_taken["k12adminstatm"]}', maceused: '#{actions_taken["maceused"]}' , actionsnone: '#{actions_taken["none"]}', otherphysicalvehicle: '#{actions_taken["otherphysicalvehicle"]}', photographed: '#{actions_taken["photographed"]}', removedbycontact: '#{actions_taken["removedbycontact"]}',removedbyorder: '#{actions_taken["removedbyorder"]}', rubberbulletsused: '#{actions_taken["rubberbulletsused"]}', stungunused: '#{actions_taken["stungunused"]}' } } ] WHERE doj_record_id= '#{@doj_record_id}';")
  end

  def property_seized
    #raise cookies["basisforsearch"].inspect
    reason_for_stop = JSON.parse(cookies["reason_for_stop"])
    person_details = JSON.parse(cookies["person_details"])
    actions_taken = JSON.parse(cookies["actions_taken"])
    basisforsearch = JSON.parse(cookies["basisforsearch"])
    @resp_to_svc_call = reason_for_stop["resp_to_svc_call"]
    @prireasonforstop = reason_for_stop["prireasonforstop"]
    @reasonforstopnarrative = reason_for_stop["reasonforstopnarrative"]
    @suspicion_offense_cd = reason_for_stop["suspicion_offense_cd"]
    @trafficviolation = reason_for_stop["trafficviolation"]
    @trafficviolationoffensecd = reason_for_stop["trafficviolationoffensecd"]
    @perceived_disabilities = person_details["perceived_disabilities"]
    @person_is_student = person_details["person_is_student"]
    @perceived_lgbt = person_details["perceived_lgbt"] == "yes" ? true : false
    @gendernonconforming = person_details["gendernonconforming"]
    @perceived_age = person_details["perceived_age"].to_i
    @ethnicity = person_details["ethnicity"]
    @perceived_race_gender = person_details["gender"]
    @stopforastudent = person_details["stopforastudent"] == "yes" ? true : false
    @lgbt = person_details["lgbt"]
    @limitedenglish = person_details["limitedenglish"]
    @perceived_race_set = person_details["ethnicity"]
    @resp_to_svc_call = reason_for_stop["resp_to_svc_call"]
    @doj_record_id = session[:doj_record_id]
    cookies["property_seized"] = JSON.generate({"firearm_p" => params["firearm_p"], "ammunition_p" => params["ammunition_p"], "otherweapon_p" => params["otherweapon_p"], "drugs_p" => params["drugs_p"], "alcohol_p" => params["alcohol_p"], "money_p" => params["money_p"], "drugparaphen_p" => params["drugparaphen_p"],
    "suspectedstolenproperty_p" => params["suspectedstolenproperty_p"], "cellphone_p" => params["cellphone_p"], "vehicle_p" => params["vehicle_p"], "otherevidencecontraband_p" => params["otherevidencecontraband_p"], "safekeeping" => params["safekeeping"], "contraband" =>  params["contraband"], "evidence"=>  params["evidence"], "impoundvehicle" =>  params["impoundvehicle"],  "abandonedproperty" => params["abandonedproperty"], "k12violationschoolpolicy" =>  params["k12violationschoolpolicy"] })
    @session.execute("UPDATE stopdata_by_doj_record_id SET resp_to_svc_call ='#{@resp_to_svc_call}', persondata= [{ typeofpropertyseized: {firearm_p: '#{params["firearm_p"]}', ammunition_p: '#{params["ammunition_p"]}', otherweapon_p: '#{params["otherweapon_p"]}', drugs_p: '#{params["drugs_p"]}', alcohol_p: '#{params["alcohol_p"]}', money_p: '#{params["money_p"]}', drugparaphen_p: '#{params["drugparaphen_p"]}', suspectedstolenproperty_p: '#{params["suspectedstolenproperty_p"]}', cellphone_p: '#{params["cellphone_p"]}', vehicle_p: '#{params["vehicle_p"]}', otherevidencecontraband_p: '#{params["otherevidencecontraband_p"]}'}, basisforpropertyseizure: {safekeeping: '#{params["safekeeping"]}', contraband: '#{params["contraband"]}', evidence: '#{params["evidence"]}', impoundvehicle: '#{params["impoundvehicle"]}',  abandonedproperty: '#{params["abandonedproperty"]}', k12violationschoolpolicy: '#{params["k12violationschoolpolicy"]}'}, basisforsearch: {basisforsearchnarrative: '#{basisforsearch["basisforsearchnarrative"]}', consentgiven: '#{basisforsearch["consentgiven"]}', officersafety: '#{basisforsearch["officersafety"]}', searchwarrant: '#{basisforsearch["searchwarrant"]}', conditionofparole: '#{basisforsearch["conditionofparole"]}', suspectedweapon: '#{basisforsearch["suspectedweapon"]}', visiblecontraband: '#{basisforsearch["visiblecontraband"]}', odorofcontraband: '#{basisforsearch["odorofcontraband"]}', caninedetection: '#{basisforsearch["caninedetection"]}', evidenceofcrime: '#{basisforsearch["evidenceofcrime"]}', exigentcircumstances: '#{basisforsearch["exigentcircumstances"]}' },  perceptiondata: {k12hyper: 'yes', ethnicity: {'#{@perceived_race_set}'}, gender: '#{@perceived_race_gender}',age: #{@perceived_age}, disability: {'#{@perceived_disabilities}'}, stopforastudent: #{@stopforastudent}, gendernonconforming: #{@gendernonconforming}, lgbt: #{@perceived_lgbt}, limitedenglish: '#{@limitedenglish}' }, personnum: 34, primaryreason: {edu_cd_sect: 'yes', edu_cd_subdiv: '#{@perceived_race_set}', prireasonforstop: '#{@prireasonforstop}', reasonforstopnarrative: '#{@reasonforstopnarrative}', st_casing: 'yes', st_drugtxn: 'yes', st_lookout: 'yes', st_matcheddesc: 'yes', st_officerwitnessed: 'yes', st_other: 'yes', st_suspiciousobjt: 'yes', st_violentcrime: 'yes', st_witnessid: 'yes', suspicion_offense_cd: '#{@suspicion_offense_cd}', trafficviolation: '#{@trafficviolation}', traffic_violation_offense_cd: '#{@trafficviolationoffensecd}' }, actionstaken: {batonused: '#{actions_taken["batonused"]}', caninebit: '#{actions_taken["caninebit"]}', canineused: '#{actions_taken["canineused"]}', cardetention: '#{actions_taken["cardetention"]}', cuffed: '#{actions_taken["cuffed"]}', curbsidedetention: '#{actions_taken["curbsidedetention"]}', fieldsobrietytest: '#{actions_taken["fieldsobrietytest"]}', firearmpointed: '#{actions_taken["firearmpointed"]}', firearmused: '#{actions_taken["firearmused"]}', k12admstatm: '#{actions_taken["k12adminstatm"]}', maceused: '#{actions_taken["maceused"]}' , actionsnone: '#{actions_taken["none"]}', otherphysicalvehicle: '#{actions_taken["otherphysicalvehicle"]}', photographed: '#{actions_taken["photographed"]}', removedbycontact: '#{actions_taken["removedbycontact"]}',removedbyorder: '#{actions_taken["removedbyorder"]}', rubberbulletsused: '#{actions_taken["rubberbulletsused"]}', stungunused: '#{actions_taken["stungunused"]}' } } ] WHERE doj_record_id= '#{@doj_record_id}';")

  end

  def k12_related

  end

  def result_of_stop
    reason_for_stop = JSON.parse(cookies["reason_for_stop"])
    person_details = JSON.parse(cookies["person_details"])
    actions_taken = JSON.parse(cookies["actions_taken"])
    basisforsearch = JSON.parse(cookies["basisforsearch"])
    property_seized = JSON.parse(cookies["property_seized"])
    contraband_evidence = JSON.parse(cookies["contraband_evidence"])
    @resp_to_svc_call = reason_for_stop["resp_to_svc_call"]
    @prireasonforstop = reason_for_stop["prireasonforstop"]
    @reasonforstopnarrative = reason_for_stop["reasonforstopnarrative"]
    @suspicion_offense_cd = reason_for_stop["suspicion_offense_cd"]
    @trafficviolation = reason_for_stop["trafficviolation"]
    @trafficviolationoffensecd = reason_for_stop["trafficviolationoffensecd"]
    @perceived_disabilities = person_details["perceived_disabilities"]
    @person_is_student = person_details["person_is_student"]
    @perceived_lgbt = person_details["perceived_lgbt"] == "yes" ? true : false
    @gendernonconforming = person_details["gendernonconforming"]
    @perceived_age = person_details["perceived_age"].to_i
    @ethnicity = person_details["ethnicity"]
    @perceived_race_gender = person_details["gender"]
    @stopforastudent = person_details["stopforastudent"] == "yes" ? true : false
    @lgbt = person_details["lgbt"]
    @limitedenglish = person_details["limitedenglish"]
    @perceived_race_set = person_details["ethnicity"]
    @resp_to_svc_call = reason_for_stop["resp_to_svc_call"]
    @doj_record_id = session[:doj_record_id]
    cookies["resultofstop"] = JSON.generate({ "citation_offense_cd" => {}, "citationorinfraction" => params["citationorinfraction"], "cite_offense_cd" => {}, "contactedparent": params["contactedparent"], "custodial_arrest_offense_cd": {}, "custodialarrestnowarr": params["custodialarrestnowarr"], "custodialarrestwarr": params["custodialarrestwarr"], "fieldcard" => params["custodialarrestwarr"], "homelandsecureferral" => params["homelandsecureferral"], "infieldciteandrel" => params["infieldciteandrel"], "k12referadministrator" => params["k12referadministrator"] , "k12refercounselor" => params["k12refercounselor"], "noaction" => params["noaction"], "noncrimtransport" => params["noncrimtransport"], "psychiatrichold" => params["psychiatrichold"], "warning" => params["warning"], "warning_offense_cd" => params["warning_offense_cd"] })
    @session.execute("UPDATE stopdata_by_doj_record_id SET resp_to_svc_call ='#{@resp_to_svc_call}', persondata= [{ resultofstop: { citation_offense_cd: {}, citationorinfraction: '#{params["citationorinfraction"]}', cite_offense_cd: {}, contactedparent: '#{params["contactedparent"]}', custodial_arrest_offense_cd: {}, custodialarrestnowarr: '#{params["custodialarrestnowarr"]}', custodialarrestwarr: '#{params["custodialarrestwarr"]}', fieldcard: '#{params["custodialarrestwarr"]}', homelandsecureferral: '#{params["homelandsecureferral"]}', infieldciteandrel: '#{params["infieldciteandrel"]}', k12referadministrator: '#{params["k12referadministrator"]}' , k12refercounselor: '#{params["k12refercounselor"]}', noaction: '#{params["noaction"]}', noncrimtransport: '#{params["noncrimtransport"]}', psychiatrichold: '#{params["psychiatrichold"]}', warning: '#{params["warning"]}', warning_offense_cd: {'#{params["warning_offense_cd"]}' }}, contrabandorevidenceset: {alcohol: '#{contraband_evidence["alcohol"]}', ammunition: '#{contraband_evidence["ammunition"]}', cellphone: '#{contraband_evidence["cellphone"]}', drugparaphen: '#{contraband_evidence["drugparaphen"]}', drugs: '#{contraband_evidence["drugs"]}', firearm: '#{contraband_evidence["firearm"]}', money: '#{contraband_evidence["money"]}', none: '#{contraband_evidence["none"]}', othercontraband: '#{contraband_evidence["othercontraband"]}', otherweapon: '#{contraband_evidence["otherweapon"]}', suspectedstolenproperty: '#{contraband_evidence["suspectedstolenproperty"]}'}, typeofpropertyseized: {firearm_p: '#{property_seized["firearm_p"]}', ammunition_p: '#{property_seized["ammunition_p"]}', otherweapon_p: '#{property_seized["otherweapon_p"]}', drugs_p: '#{property_seized["drugs_p"]}', alcohol_p: '#{property_seized["alcohol_p"]}', money_p: '#{property_seized["money_p"]}', drugparaphen_p: '#{property_seized["drugparaphen_p"]}', suspectedstolenproperty_p: '#{property_seized["suspectedstolenproperty_p"]}', cellphone_p: '#{property_seized["cellphone_p"]}', vehicle_p: '#{property_seized["vehicle_p"]}', otherevidencecontraband_p: '#{property_seized["otherevidencecontraband_p"]}'}, basisforpropertyseizure: {safekeeping: '#{property_seized["safekeeping"]}', contraband: '#{property_seized["contraband"]}', evidence: '#{property_seized["evidence"]}', impoundvehicle: '#{property_seized["impoundvehicle"]}',  abandonedproperty: '#{property_seized["abandonedproperty"]}', k12violationschoolpolicy: '#{property_seized["k12violationschoolpolicy"]}'}, basisforsearch: {basisforsearchnarrative: '#{basisforsearch["basisforsearchnarrative"]}', consentgiven: '#{basisforsearch["consentgiven"]}', officersafety: '#{basisforsearch["officersafety"]}', searchwarrant: '#{basisforsearch["searchwarrant"]}', conditionofparole: '#{basisforsearch["conditionofparole"]}', suspectedweapon: '#{basisforsearch["suspectedweapon"]}', visiblecontraband: '#{basisforsearch["visiblecontraband"]}', odorofcontraband: '#{basisforsearch["odorofcontraband"]}', caninedetection: '#{basisforsearch["caninedetection"]}', evidenceofcrime: '#{basisforsearch["evidenceofcrime"]}', exigentcircumstances: '#{basisforsearch["exigentcircumstances"]}' },  perceptiondata: {k12hyper: 'yes', ethnicity: {'#{@perceived_race_set}'}, gender: '#{@perceived_race_gender}',age: #{@perceived_age}, disability: {'#{@perceived_disabilities}'}, stopforastudent: #{@stopforastudent}, gendernonconforming: #{@gendernonconforming}, lgbt: #{@perceived_lgbt}, limitedenglish: '#{@limitedenglish}' }, personnum: 34, primaryreason: {edu_cd_sect: 'yes', edu_cd_subdiv: '#{@perceived_race_set}', prireasonforstop: '#{@prireasonforstop}', reasonforstopnarrative: '#{@reasonforstopnarrative}', st_casing: 'yes', st_drugtxn: 'yes', st_lookout: 'yes', st_matcheddesc: 'yes', st_officerwitnessed: 'yes', st_other: 'yes', st_suspiciousobjt: 'yes', st_violentcrime: 'yes', st_witnessid: 'yes', suspicion_offense_cd: '#{@suspicion_offense_cd}', trafficviolation: '#{@trafficviolation}', traffic_violation_offense_cd: '#{@trafficviolationoffensecd}' }, actionstaken: {batonused: '#{actions_taken["batonused"]}', caninebit: '#{actions_taken["caninebit"]}', canineused: '#{actions_taken["canineused"]}', cardetention: '#{actions_taken["cardetention"]}', cuffed: '#{actions_taken["cuffed"]}', curbsidedetention: '#{actions_taken["curbsidedetention"]}', fieldsobrietytest: '#{actions_taken["fieldsobrietytest"]}', firearmpointed: '#{actions_taken["firearmpointed"]}', firearmused: '#{actions_taken["firearmused"]}', k12admstatm: '#{actions_taken["k12adminstatm"]}', maceused: '#{actions_taken["maceused"]}' , actionsnone: '#{actions_taken["none"]}', otherphysicalvehicle: '#{actions_taken["otherphysicalvehicle"]}', photographed: '#{actions_taken["photographed"]}', removedbycontact: '#{actions_taken["removedbycontact"]}',removedbyorder: '#{actions_taken["removedbyorder"]}', rubberbulletsused: '#{actions_taken["rubberbulletsused"]}', stungunused: '#{actions_taken["stungunused"]}' } } ] WHERE doj_record_id= '#{@doj_record_id}';")
  end

  def contraband_evidence
    reason_for_stop = JSON.parse(cookies["reason_for_stop"])
    person_details = JSON.parse(cookies["person_details"])
    actions_taken = JSON.parse(cookies["actions_taken"])
    basisforsearch = JSON.parse(cookies["basisforsearch"])
    property_seized = JSON.parse(cookies["property_seized"])
    @resp_to_svc_call = reason_for_stop["resp_to_svc_call"]
    @prireasonforstop = reason_for_stop["prireasonforstop"]
    @reasonforstopnarrative = reason_for_stop["reasonforstopnarrative"]
    @suspicion_offense_cd = reason_for_stop["suspicion_offense_cd"]
    @trafficviolation = reason_for_stop["trafficviolation"]
    @trafficviolationoffensecd = reason_for_stop["trafficviolationoffensecd"]
    @perceived_disabilities = person_details["perceived_disabilities"]
    @person_is_student = person_details["person_is_student"]
    @perceived_lgbt = person_details["perceived_lgbt"] == "yes" ? true : false
    @gendernonconforming = person_details["gendernonconforming"]
    @perceived_age = person_details["perceived_age"].to_i
    @ethnicity = person_details["ethnicity"]
    @perceived_race_gender = person_details["gender"]
    @stopforastudent = person_details["stopforastudent"] == "yes" ? true : false
    @lgbt = person_details["lgbt"]
    @limitedenglish = person_details["limitedenglish"]
    @perceived_race_set = person_details["ethnicity"]
    @resp_to_svc_call = reason_for_stop["resp_to_svc_call"]
    @doj_record_id = session[:doj_record_id]
    cookies["contraband_evidence"] = JSON.generate({"alcohol" => params["alcohol"], "ammunition"=> params["ammunition"], "cellphone"=> params["cellphone"], "drugparaphen"=> params["drugparaphen"], "drugs"=> params["drugs"], "firearm"=> params["firearm"], "money"=> params["money"], "none"=> params["none"], "othercontraband"=> params["othercontraband"], "otherweapon"=> params["otherweapon"], "suspectedstolenproperty"=> params["suspectedstolenproperty"]  })
    @session.execute("UPDATE stopdata_by_doj_record_id SET resp_to_svc_call ='#{@resp_to_svc_call}', persondata= [{ contrabandorevidenceset: {alcohol: '#{params["alcohol"]}', ammunition: '#{params["ammunition"]}', cellphone: '#{params["cellphone"]}', drugparaphen: '#{params["drugparaphen"]}', drugs: '#{params["drugs"]}', firearm: '#{params["firearm"]}', money: '#{params["money"]}', none: '#{params["none"]}', othercontraband: '#{params["othercontraband"]}', otherweapon: '#{params["otherweapon"]}', suspectedstolenproperty: '#{params["suspectedstolenproperty"]}'}, typeofpropertyseized: {firearm_p: '#{property_seized["firearm_p"]}', ammunition_p: '#{property_seized["ammunition_p"]}', otherweapon_p: '#{property_seized["otherweapon_p"]}', drugs_p: '#{property_seized["drugs_p"]}', alcohol_p: '#{property_seized["alcohol_p"]}', money_p: '#{property_seized["money_p"]}', drugparaphen_p: '#{property_seized["drugparaphen_p"]}', suspectedstolenproperty_p: '#{property_seized["suspectedstolenproperty_p"]}', cellphone_p: '#{property_seized["cellphone_p"]}', vehicle_p: '#{property_seized["vehicle_p"]}', otherevidencecontraband_p: '#{property_seized["otherevidencecontraband_p"]}'}, basisforpropertyseizure: {safekeeping: '#{property_seized["safekeeping"]}', contraband: '#{property_seized["contraband"]}', evidence: '#{property_seized["evidence"]}', impoundvehicle: '#{property_seized["impoundvehicle"]}',  abandonedproperty: '#{property_seized["abandonedproperty"]}', k12violationschoolpolicy: '#{property_seized["k12violationschoolpolicy"]}'}, basisforsearch: {basisforsearchnarrative: '#{basisforsearch["basisforsearchnarrative"]}', consentgiven: '#{basisforsearch["consentgiven"]}', officersafety: '#{basisforsearch["officersafety"]}', searchwarrant: '#{basisforsearch["searchwarrant"]}', conditionofparole: '#{basisforsearch["conditionofparole"]}', suspectedweapon: '#{basisforsearch["suspectedweapon"]}', visiblecontraband: '#{basisforsearch["visiblecontraband"]}', odorofcontraband: '#{basisforsearch["odorofcontraband"]}', caninedetection: '#{basisforsearch["caninedetection"]}', evidenceofcrime: '#{basisforsearch["evidenceofcrime"]}', exigentcircumstances: '#{basisforsearch["exigentcircumstances"]}' },  perceptiondata: {k12hyper: 'yes', ethnicity: {'#{@perceived_race_set}'}, gender: '#{@perceived_race_gender}',age: #{@perceived_age}, disability: {'#{@perceived_disabilities}'}, stopforastudent: #{@stopforastudent}, gendernonconforming: #{@gendernonconforming}, lgbt: #{@perceived_lgbt}, limitedenglish: '#{@limitedenglish}' }, personnum: 34, primaryreason: {edu_cd_sect: 'yes', edu_cd_subdiv: '#{@perceived_race_set}', prireasonforstop: '#{@prireasonforstop}', reasonforstopnarrative: '#{@reasonforstopnarrative}', st_casing: 'yes', st_drugtxn: 'yes', st_lookout: 'yes', st_matcheddesc: 'yes', st_officerwitnessed: 'yes', st_other: 'yes', st_suspiciousobjt: 'yes', st_violentcrime: 'yes', st_witnessid: 'yes', suspicion_offense_cd: '#{@suspicion_offense_cd}', trafficviolation: '#{@trafficviolation}', traffic_violation_offense_cd: '#{@trafficviolationoffensecd}' }, actionstaken: {batonused: '#{actions_taken["batonused"]}', caninebit: '#{actions_taken["caninebit"]}', canineused: '#{actions_taken["canineused"]}', cardetention: '#{actions_taken["cardetention"]}', cuffed: '#{actions_taken["cuffed"]}', curbsidedetention: '#{actions_taken["curbsidedetention"]}', fieldsobrietytest: '#{actions_taken["fieldsobrietytest"]}', firearmpointed: '#{actions_taken["firearmpointed"]}', firearmused: '#{actions_taken["firearmused"]}', k12admstatm: '#{actions_taken["k12adminstatm"]}', maceused: '#{actions_taken["maceused"]}' , actionsnone: '#{actions_taken["none"]}', otherphysicalvehicle: '#{actions_taken["otherphysicalvehicle"]}', photographed: '#{actions_taken["photographed"]}', removedbycontact: '#{actions_taken["removedbycontact"]}',removedbyorder: '#{actions_taken["removedbyorder"]}', rubberbulletsused: '#{actions_taken["rubberbulletsused"]}', stungunused: '#{actions_taken["stungunused"]}' } } ] WHERE doj_record_id= '#{@doj_record_id}';")
  end



  def stop_summary
    reason_for_stop = JSON.parse(cookies["reason_for_stop"])
    person_details = JSON.parse(cookies["person_details"])
    actions_taken = JSON.parse(cookies["actions_taken"])
    basisforsearch = JSON.parse(cookies["basisforsearch"])
    property_seized = JSON.parse(cookies["property_seized"])
    resultofstop = JSON.parse(cookies["resultofstop"])
    
    @doj_record_id = session[:doj_record_id]
  end

end
