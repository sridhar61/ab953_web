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
    @response_to_call_service = params["response_to_call_service"] == "true" ? true : false
    count_records = @session.execute("select count(*) from stopdata_by_doj_record_id where agency_ori= 'CA9876432'  ALLOW FILTERING;");
    total_records = count_records.rows.first["count"]
    date_of_stop = date_format(params["date_of_stop"])
    doj_record_id = doj_record_id(params["date_of_stop"], total_records)
    time_of_stop = params["time_of_stop"]+":00.000"
    agency_ori = "CA9876432"
    cookies["initial_stop"] = JSON.generate({ "response_to_call_service" =>  @response_to_call_service })
    stop_data = @session.execute("INSERT INTO stopdata_by_doj_record_id (doj_record_id, agency_ori, dateofstop ,
    starttimeofstop ,durationofstop, resp_to_svc_call, officer, createtime) values  ( '#{doj_record_id}',
    '#{agency_ori}', '#{date_of_stop}' ,'#{time_of_stop}',#{params["duration_of_stop"].to_i}, #{@response_to_call_service},
    {officer_uid: '01', proxylogin: '09', officeryearsofexperience: #{params["experience"].to_i},
    officertypeofassignment: '#{params["assignment_type"]}',
    officerotherassignmenttype: '#{params["other_assingment_type"]}' },
    '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}');")
    session[:doj_record_id] = doj_record_id
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
    @gendernonconforming = params[:perceived_gender_non_confirming]
    @limitedenglish = params[:perceived_english_fluency] == "yes" ? true : false
    @perceived_race_gender = params[:perceived_race_gender].to_i
    @perceived_race_set = params[:perceived_race_set].join(',')
    #a = { "perceived_disabilities" => "123"}
    #raise a.inspect
    #b = { "perceived_disabilities" => @perceived_disabilities, "person_is_student" => params["person_is_student"],"perceived_lgbt" => params["perceived_lgbt"], "gendernonconforming" => @gendernonconforming}
    #raise b.inspect
    cookies["person_details"] = JSON.generate({ "perceived_disabilities" => @perceived_disabilities,
    "person_is_student" => @person_is_student,"perceived_lgbt" => @perceived_lgbt,
    "gendernonconforming" => @gendernonconforming, "age" => params["perceived_age"].to_i, "ethnicity" => @perceived_race_set,
    "gender" => @perceived_race_gender, "limitedenglish" => @limitedenglish })

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
    @session.execute("UPDATE stopdata_by_doj_record_id SET persondata= [{ perceptiondata: {
    ethnicity_set: {'#{@perceived_race_set}'}, gender_key: '#{@perceived_race_gender}', age: #{params["perceived_age"].to_i},
    disability_set: {'#{@perceived_disabilities}'}, stopforastudent: #{@person_is_student},
    gendernonconforming: '#{@gendernonconforming}', lgbt: #{@perceived_lgbt}, limitedenglish: #{@limitedenglish} } }]
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
    #raise params.inspect
    person_details = JSON.parse(cookies["person_details"])
    @perceived_disabilities = person_details["perceived_disabilities"]
    @person_is_student = person_details["person_is_student"]
    @perceived_lgbt = person_details["perceived_lgbt"]
    @gendernonconforming = person_details["gendernonconforming"]
    @perceived_age = person_details["perceived_age"].to_i
    @ethnicity = person_details["ethnicity"]
    @gender = person_details["gender"]
    @suspicion_sub_types = params["suspicion_sub_types"].present? ? params["suspicion_sub_types"].join(',') : ""
    @limitedenglish = person_details["limitedenglish"]
    @perceived_race_set = person_details["ethnicity"]
    @perceived_race_gender = person_details["gender"]
    @age = person_details["age"]
    @doj_record_id = session[:doj_record_id]
    cookies["reason_for_stop"] = JSON.generate({ "trafficviolation_id" => params["type_of_traffic_violation"], "traffic_violation_offense_cd" => params["violation_suspicion_cjis_offense_code"].to_i, "edu_cd_sec_id" => params["education_code"], "edu_cd_subdiv_id" => params["sub_education_code"], "prireasonforstop_key" => params["select_reason_for_stop"], "reasonforstopnarrative" => params["reason_for_stop_explaination"], "suspicion_offense_cd" => params["suspicion_cjis_offense_code"].to_i, "suspicion_subtype_set" => @suspicion_sub_types })

    @session.execute("UPDATE stopdata_by_doj_record_id SET persondata= [{ perceptiondata: {ethnicity_set: {'#{@perceived_race_set}'}, gender_key: '#{@perceived_race_gender}',age: #{@age}, disability_set: {'#{@perceived_disabilities}'}, gendernonconforming: '#{@gendernonconforming}', lgbt: #{@perceived_lgbt}, limitedenglish: #{@limitedenglish} }, personnum: 34, primaryreason: {edu_cd_sec_id: '#{params["education_code"]}', edu_cd_subdiv_id: '#{params["sub_education_code"]}', prireasonforstop_key: '#{params["select_reason_for_stop"]}', reasonforstopnarrative: '#{params["reason_for_stop_explaination"]}', suspicion_offense_cd: #{params["suspicion_cjis_offense_code"].to_i}, suspicion_subtype_set: {'#{@suspicion_sub_types}' } , trafficviolation_id: '#{params["type_of_traffic_violation"]}', traffic_violation_offense_cd: #{params["violation_suspicion_cjis_offense_code"].to_i} } }] WHERE doj_record_id= '#{@doj_record_id}'; ")
  end


  def post_stop_action

  end

  def search

  end

  def action_taken
    @actions_taken = params["actionstaken"]
    @actions_taken_collection = {}
    reason_for_stop = JSON.parse(cookies["reason_for_stop"])
    person_details = JSON.parse(cookies["person_details"])
    @resp_to_svc_call = reason_for_stop["resp_to_svc_call"]
    @prireasonforstop = reason_for_stop["prireasonforstop_key"]
    @reasonforstopnarrative = reason_for_stop["reasonforstopnarrative"]
    @suspicion_offense_cd = reason_for_stop["suspicion_offense_cd"]
    @suspicion_subtype_set = reason_for_stop["suspicion_subtype_set"]
    @trafficviolation = reason_for_stop["trafficviolation_id"]
    @trafficviolationoffensecd = reason_for_stop["trafficviolationoffensecd"]
    @perceived_disabilities = person_details["perceived_disabilities"]
    @person_is_student = person_details["person_is_student"]
    @perceived_lgbt = person_details["perceived_lgbt"]
    @gendernonconforming = person_details["gendernonconforming"]
    @perceived_age = person_details["perceived_age"].to_i
    @ethnicity = person_details["ethnicity"]
    @perceived_race_gender = person_details["gender"]
    @edu_cd_sec_id = reason_for_stop["edu_cd_sec_id"]
    @edu_cd_subdiv_id = reason_for_stop["edu_cd_subdiv_id"]
    @limitedenglish = person_details["limitedenglish"]
    @perceived_race_set = person_details["ethnicity"]
    @resp_to_svc_call = reason_for_stop["resp_to_svc_call"]
    @doj_record_id = session[:doj_record_id]
    @actions_taken.each do |action_taken|
       a = { action_taken => true }
      @actions_taken_collection.merge!(a)
    end
    string = generate_string(@actions_taken_collection)
    query = "UPDATE stopdata_by_doj_record_id SET persondata=" +  "[{ action_set: {#{string}} }]" + "WHERE doj_record_id= '#{@doj_record_id}';"

    #raise query.inspect
    #batch = @session.batch

    #statement = batch.add("UPDATE stopdata_by_doj_record_id SET persondata=? WHERE doj_record_id=?")
    #raise  @actions_taken_collection.inspect
    #batch = statement.bind(@actions_taken_collection, @doj_record_id)

    #@session.execute(batch)
    #@session.execute([{ action_set:@actions_taken_collection}], @doj_record_id);

    cookies["actions_taken"] = JSON.generate({ "actions_taken" => @actions_taken_collection})
    #raise "UPDATE stopdata_by_doj_record_id SET persondata= [{ action_set: #{@parsed_actions_taken_collection} }] WHERE doj_record_id= '#{@doj_record_id}';".inspect
    @session.execute(query)
    #@session.execute("UPDATE stopdata_by_doj_record_id SET persondata= [{ action_set: #{@parsed_actions_taken_collection} }] WHERE doj_record_id= '#{@doj_record_id}';")
  end


  def generate_string(actions_taken)
    a = ""
    actions_taken.each do |x|
      a += "'#{x[0]}' : #{x[1]}" + ","
    end
    b = a.chomp(",")

  end

  def basis_for_search
    #raise params.inspect
    reason_for_stop = JSON.parse(cookies["reason_for_stop"])
    person_details = JSON.parse(cookies["person_details"])
    actions_taken = JSON.parse(cookies["actions_taken"])
    #raise person_details.inspect
    @edu_cd_sec_id, @edu_cd_subdiv_id, @prireasonforstop, @reasonforstopnarrative, @suspicion_offense_cd, @suspicion_subtype_set, @trafficviolation, @trafficviolationoffensecd = get_reason_details(reason_for_stop)
    @perceived_disabilities, @person_is_student, @perceived_lgbt, @gendernonconforming, @perceived_age, @ethnicity, @perceived_race_gender, @stopforastudent, @lgbt, @limitedenglish, @perceived_race_set = get_person_details(person_details)

    @doj_record_id = session[:doj_record_id]
    @result_of_stop = params["result_of_stop"].present? ? params["result_of_stop"].join(',') : ""
    #raise @result_of_stop.inspect
    @actions_taken_collection = actions_taken["actions_taken"]
    string = generate_string(@actions_taken_collection)
    cookies["basisforsearch"] = JSON.generate({ "basisforsearch" => @result_of_stop, "basisforsearchnarrative" => params["basisforsearchnarrative"] })
    query = "UPDATE stopdata_by_doj_record_id SET persondata=" + "[{ action_set: {#{string}}, " + "basis_for_search_set: {'#{@result_of_stop}'}, basisforsearchnarrative:  '#{params["basisforsearchnarrative"]}',  perceptiondata: {ethnicity_set: {'#{@perceived_race_set}'}, gender_key: '#{@perceived_race_gender}',age: #{@perceived_age}, disability_set: {'#{@perceived_disabilities}'}, gendernonconforming: '#{@gendernonconforming}', lgbt: #{@perceived_lgbt}, limitedenglish: #{@limitedenglish} }, personnum: 34, primaryreason: {edu_cd_sec_id: '#{@edu_cd_sec_id}', edu_cd_subdiv_id: '#{@edu_cd_subdiv_id}', prireasonforstop_key: '#{@prireasonforstop_key}', reasonforstopnarrative: '#{@reasonforstopnarrative}', suspicion_offense_cd: #{@suspicion_offense_cd.to_i}, suspicion_subtype_set: {'#{@suspicion_subtype_set}' } , trafficviolation_id: '#{@trafficviolation_id}', traffic_violation_offense_cd: #{@traffic_violation_offense_cd.to_i} } }] WHERE doj_record_id= '#{@doj_record_id}';"
    #raise query.inspect
    @session.execute(query)
  end


  def get_person_details(person_details)
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
    return @perceived_disabilities, @person_is_student, @perceived_lgbt, @gendernonconforming, @perceived_age, @ethnicity, @perceived_race_gender, @stopforastudent, @lgbt, @limitedenglish, @perceived_race_set
  end

  def get_reason_details(reason_for_stop)
    @edu_cd_sec_id = reason_for_stop["edu_cd_sec_id"]
    @edu_cd_subdiv_id = reason_for_stop["edu_cd_subdiv_id"]
    @prireasonforstop = reason_for_stop["prireasonforstop_key"]
    @reasonforstopnarrative = reason_for_stop["reasonforstopnarrative"]
    @suspicion_offense_cd = reason_for_stop["suspicion_offense_cd"]
    @suspicion_subtype_set = reason_for_stop["suspicion_subtype_set"]
    @trafficviolation = reason_for_stop["trafficviolation_id"]
    @trafficviolationoffensecd = reason_for_stop["traffic_violation_offense_cd"]
    return @edu_cd_sec_id, @edu_cd_subdiv_id, @prireasonforstop, @reasonforstopnarrative, @suspicion_offense_cd, @suspicion_subtype_set, @trafficviolation, @trafficviolationoffensecd
  end

  def property_seized
    #raise params["basis_for_property_seizure_set"].inspect
    reason_for_stop = JSON.parse(cookies["reason_for_stop"])
    person_details = JSON.parse(cookies["person_details"])
    actions_taken = JSON.parse(cookies["actions_taken"])
    basisforsearch = JSON.parse(cookies["basisforsearch"])
    @actions_taken_collection = actions_taken["actions_taken"]
    basis_for_search_set = basisforsearch["basisforsearch"]
    basisforsearchnarrative = basisforsearch["basisforsearchnarrative"]
    @property_seized = params["property_seized"].present? ? params["property_seized"].join(',') : ""
    @propety_seized_set = params["property_seized_type"].present? ? params["property_seized_type"].join(',') : ""

    string = generate_string(@actions_taken_collection)
    #raise person_details.inspect
    @edu_cd_sec_id, @edu_cd_subdiv_id, @prireasonforstop, @reasonforstopnarrative, @suspicion_offense_cd, @suspicion_subtype_set, @trafficviolation, @trafficviolationoffensecd = get_reason_details(reason_for_stop)
    @perceived_disabilities, @person_is_student, @perceived_lgbt, @gendernonconforming, @perceived_age, @ethnicity, @perceived_race_gender, @stopforastudent, @lgbt, @limitedenglish, @perceived_race_set = get_person_details(person_details)

    @doj_record_id = session[:doj_record_id]
    cookies["property_seized"] = JSON.generate({"basis_for_property_seizure_set" => params["property_seized"], "propety_seized_set" => params["property_seized_type"] })


    query = "UPDATE stopdata_by_doj_record_id SET persondata=" + "[{ action_set: {#{string}}, " + "basis_for_search_set: {'#{basis_for_search_set}'},  basis_for_property_seizure_set: {'#{@property_seized}'}, propety_seized_set: {'#{@propety_seized_set}'}, basisforsearchnarrative:  '#{basisforsearchnarrative}',  perceptiondata: {ethnicity_set: {'#{@perceived_race_set}'}, gender_key: '#{@perceived_race_gender}',age: #{@perceived_age}, disability_set: {'#{@perceived_disabilities}'}, gendernonconforming: '#{@gendernonconforming}', lgbt: #{@perceived_lgbt}, limitedenglish: #{@limitedenglish}, stopforastudent: #{@person_is_student} }, personnum: 34, primaryreason: {edu_cd_sec_id: '#{@edu_cd_sec_id}', edu_cd_subdiv_id: '#{@edu_cd_subdiv_id}', prireasonforstop_key: '#{@prireasonforstop}', reasonforstopnarrative: '#{@reasonforstopnarrative}', suspicion_offense_cd: #{@suspicion_offense_cd.to_i}, suspicion_subtype_set: {'#{@suspicion_subtype_set}' } , trafficviolation_id: '#{@trafficviolation_id}', traffic_violation_offense_cd: #{@traffic_violation_offense_cd.to_i} } }] WHERE doj_record_id= '#{@doj_record_id}';"
    #raise query.inspect
    @session.execute(query)
  end

  def k12_related

  end

  def result_of_stop
    #raise params["basis_for_property_seizure_set"].inspect
    reason_for_stop = JSON.parse(cookies["reason_for_stop"])
    person_details = JSON.parse(cookies["person_details"])
    actions_taken = JSON.parse(cookies["actions_taken"])
    basisforsearch = JSON.parse(cookies["basisforsearch"])
    @actions_taken_collection = actions_taken["actions_taken"]
    basis_for_search_set = basisforsearch["basisforsearch"]
    basisforsearchnarrative = basisforsearch["basisforsearchnarrative"]
    @property_seized = params["property_seized"].present? ? params["property_seized"].join(',') : ""
    @propety_seized_set = params["property_seized_type"].present? ? params["property_seized_type"].join(',') : ""

    string = generate_string(@actions_taken_collection)
    string_result_of_stop = generate_result_string(params)
    #raise person_details.inspect
    #raise string_result_of_stop.inspect
    @edu_cd_sec_id, @edu_cd_subdiv_id, @prireasonforstop, @reasonforstopnarrative, @suspicion_offense_cd, @suspicion_subtype_set, @trafficviolation, @trafficviolationoffensecd = get_reason_details(reason_for_stop)
    @perceived_disabilities, @person_is_student, @perceived_lgbt, @gendernonconforming, @perceived_age, @ethnicity, @perceived_race_gender, @stopforastudent, @lgbt, @limitedenglish, @perceived_race_set = get_person_details(person_details)

    @doj_record_id = session[:doj_record_id]
    #raise @doj_record_id
    cookies["property_seized"] = JSON.generate({"basis_for_property_seizure_set" => params["property_seized"], "propety_seized_set" => params["property_seized_type"] })
    query = "UPDATE stopdata_by_doj_record_id SET persondata=" + "[{ action_set: {#{string}}, " +  "result_of_stop_set: {#{string_result_of_stop}}, "  + "basis_for_search_set: {'#{basis_for_search_set}'},  basis_for_property_seizure_set: {'#{@property_seized}'}, propety_seized_set: {'#{@propety_seized_set}'}, basisforsearchnarrative:  '#{basisforsearchnarrative}',  perceptiondata: {ethnicity_set: {'#{@perceived_race_set}'}, gender_key: '#{@perceived_race_gender}',age: #{@perceived_age}, disability_set: {'#{@perceived_disabilities}'}, gendernonconforming: '#{@gendernonconforming}', lgbt: #{@perceived_lgbt}, limitedenglish: #{@limitedenglish}, stopforastudent: #{@person_is_student} }, personnum: 34, primaryreason: {edu_cd_sec_id: '#{@edu_cd_sec_id}', edu_cd_subdiv_id: '#{@edu_cd_subdiv_id}', prireasonforstop_key: '#{@prireasonforstop}', reasonforstopnarrative: '#{@reasonforstopnarrative}', suspicion_offense_cd: #{@suspicion_offense_cd.to_i}, suspicion_subtype_set: {'#{@suspicion_subtype_set}' } , trafficviolation_id: '#{@trafficviolation_id}', traffic_violation_offense_cd: #{@traffic_violation_offense_cd.to_i} } }] WHERE doj_record_id= '#{@doj_record_id}';"
    #raise query.inspect
    @session.execute(query)
  end

  def generate_result_string(params)
    query_string = ""
    result_of_stop = params["result_of_stop"]
    warning_suspicion_cjis_offense_code = params["warning_suspicion_cjis_offense_code"].present? ? params["warning_suspicion_cjis_offense_code"].join(',') : ""
    infieldcite_suspicion_cjis_offense_code = params["infieldcite_suspicion_cjis_offense_code"].present? ? params["infieldcite_suspicion_cjis_offense_code"].join(',') : ""
    custodialarrestnowarr_suspicion_cjis_offense_code = params["custodialarrestnowarr_suspicion_cjis_offense_code"].present? ? params["custodialarrestnowarr_suspicion_cjis_offense_code"].join(',') : ""
    if result_of_stop.include?("2")
      query_string += "'2': {#{warning_suspicion_cjis_offense_code}}"
      result_of_stop.delete("2")
    end
    if result_of_stop.include?("4")
      query_string += ", '4': {#{infieldcite_suspicion_cjis_offense_code}}"
      result_of_stop.delete("4")
    end
    if result_of_stop.include?("6")
      query_string += ", '6': {#{custodialarrestnowarr_suspicion_cjis_offense_code}}"
      result_of_stop.delete("6")
    end
    result_of_stop.each do |result|
      a = result
      query_string += ', ' + "'#{a}': {}"
    end
    query_string
    #raise query_string.inspect
  end

  def contraband_evidence
    reason_for_stop = JSON.parse(cookies["reason_for_stop"])
    person_details = JSON.parse(cookies["person_details"])
    actions_taken = JSON.parse(cookies["actions_taken"])
    basisforsearch = JSON.parse(cookies["basisforsearch"])
    property_seized = JSON.parse(cookies["property_seized"])
    @actions_taken_collection = actions_taken["actions_taken"]
    basis_for_search_set = basisforsearch["basisforsearch"]
    basisforsearchnarrative = basisforsearch["basisforsearchnarrative"]
    @property_seized = property_seized["basis_for_property_seizure_set"].present? ? property_seized["basis_for_property_seizure_set"].join(',') : ""
    @propety_seized_set = property_seized["propety_seized_set"].present? ? property_seized["propety_seized_set"].join(',') : ""
    @contraband_evidence = params["contraband_evidence"].present? ? params["contraband_evidence"].join(',') : ""
    string = generate_string(@actions_taken_collection)
    @edu_cd_sec_id, @edu_cd_subdiv_id, @prireasonforstop, @reasonforstopnarrative, @suspicion_offense_cd, @suspicion_subtype_set, @trafficviolation, @trafficviolationoffensecd = get_reason_details(reason_for_stop)
    @perceived_disabilities, @person_is_student, @perceived_lgbt, @gendernonconforming, @perceived_age, @ethnicity, @perceived_race_gender, @stopforastudent, @lgbt, @limitedenglish, @perceived_race_set = get_person_details(person_details)

    @doj_record_id = session[:doj_record_id]

    query = "UPDATE stopdata_by_doj_record_id SET persondata=" + "[{ action_set: {#{string}}, " + "contraband_or_evidence_set: {'#{@contraband_evidence}'}, basis_for_search_set: {'#{basis_for_search_set}'},  basis_for_property_seizure_set: {'#{@property_seized}'}, propety_seized_set: {'#{@propety_seized_set}'}, basisforsearchnarrative:  '#{basisforsearchnarrative}',  perceptiondata: {ethnicity_set: {'#{@perceived_race_set}'}, gender_key: '#{@perceived_race_gender}',age: #{@perceived_age}, disability_set: {'#{@perceived_disabilities}'}, gendernonconforming: '#{@gendernonconforming}', lgbt: #{@perceived_lgbt}, limitedenglish: #{@limitedenglish}, stopforastudent: #{@person_is_student} }, personnum: 34, primaryreason: {edu_cd_sec_id: '#{@edu_cd_sec_id}', edu_cd_subdiv_id: '#{@edu_cd_subdiv_id}', prireasonforstop_key: '#{@prireasonforstop}', reasonforstopnarrative: '#{@reasonforstopnarrative}', suspicion_offense_cd: #{@suspicion_offense_cd.to_i}, suspicion_subtype_set: {'#{@suspicion_subtype_set}' } , trafficviolation_id: '#{@trafficviolation_id}', traffic_violation_offense_cd: #{@traffic_violation_offense_cd.to_i} } }] WHERE doj_record_id= '#{@doj_record_id}';"
    #raise query.inspect
    @session.execute(query)
  end



  def stop_summary
    @doj_record_id = session[:doj_record_id]
    result = @session.execute("select * from stopdata_by_doj_record_id where doj_record_id='#{@doj_record_id}';")
    rows = result.rows
    #raise rows.inspect
    rows.each do |row|
      @doj_record_id = row["doj_record_id"]
      @dateofstop = row["dateofstop"]
      @durationofstop = row["durationofstop"]
      @starttimeofstop = row["starttimeofstop"]
      location = row["location"]
      officer = row["officer"]
      perceptiondata = row["persondata"]
      #raise perceptiondata.inspect
      @officeryearsofexperience = officer["officeryearsofexperience"]
      @officertypeofassignment = officer["officertypeofassignment"]
      @locationdescription = location["locationdescription"]
      @closestcity = location["closestcity"]
      person_details = row["persondata"]
      person_details.each do |person|
        @action_set = person["action_set"].to_a
        @person_num = person["person_num"]
        perceptiondata = person["perceptiondata"]
        @reason = person["primaryreason"]
        @reasonforstopnarrative = @reason["reasonforstopnarrative"]
        @suspicion_offense_cd = @reason["suspicion_offense_cd"]
        @suspicion_subtype_set = @reason["suspicion_subtype_set"].to_a
        @suspicion_subtype_set = @suspicion_subtype_set.join(',')
        @ethnicity_set = perceptiondata["ethnicity_set"].to_a
        @ethnicity_set = @ethnicity_set.join(',')
        @gender_key = perceptiondata["gender_key"]
        @lgbt = perceptiondata["lgbt"] == true ? "Yes" : "No"
        @age = perceptiondata["age"]
        @limitedenglish = perceptiondata["limitedenglish"] == true ? "Yes" : "No"
        @stopforastudent = perceptiondata["stopforastudent"] == true ? "Yes" : "No"
        @disability_set = perceptiondata["disability_set"].to_a
        @disability_set = @disability_set.join(',')
        #raise @gender_key.inspect
      end
      @final_action_set = get_action_for_summary(@action_set)
      @final_primaryreason, @final_suspicion_subtype = get_reason_for_summary(@reason, @suspicion_subtype_set)
      #raise @final_primaryreason.inspect
      @final_officer_assignment = officer_details_for_summary(@officertypeofassignment)
      @final_ethnicity, @final_gender, @final_disability =  get_person_details_for_summary(@ethnicity_set, @gender_key, @disability_set)
      #raise @final_disability.inspect
    end
  end

  def get_action_for_summary(action_set)

  end

  def get_reason_for_summary(reason, suspicion_subtype_set)
    #raise suspicion_subtype_set.inspect
    @final_suspicion_subtype = ""
    suspicion_subtype_set = suspicion_subtype_set.split(",")
    suspicion_subtype_set = "'#{suspicion_subtype_set.join("','")}'"
    query =  "select * from lk_lookuptables where key='lk_Susp_Sub_Type' AND column IN (#{suspicion_subtype_set})"
    suspicion_subtype = @session.execute(query);

    suspicion_subtype.rows.each do |row|
      @final_suspicion_subtype << row["value"] + ","
    end
    pri_reason = @session.execute("select * from lk_lookuptables where key='lk_prireasonforstop' AND column = '#{reason["prireasonforstop_key"]}'")
    pri_reason.rows.each do |row|
      @final_primaryreason = row["value"]
    end
    @final_suspicion_subtype = @final_suspicion_subtype.chop()

    return @final_primaryreason, @final_suspicion_subtype
  end

  def officer_details_for_summary(officertypeofassignment)
     officer_assignment = @session.execute("select * from lk_lookuptables where key='lk_assign_type' AND column = '#{officertypeofassignment}'")
     officer_assignment.rows.each do |row|
       @final_officer_assignment = row["value"]
     end
     @final_officer_assignment
  end

  def get_person_details_for_summary(ethnicity_set, gender_key, disability_set)
    ethnicity = @session.execute("select * from lk_lookuptables where key='lk_Ethnicity' AND column IN ('#{ethnicity_set}')")
    #raise "select * from lk_lookuptables where key='lk_perc_gender' AND column = '#{gender_key}'".inspect
    gender  = @session.execute("select * from lk_lookuptables where key='lk_perc_gender' AND column = '#{gender_key}'")
    #raise "select * from lk_lookuptables where key='lk_Disabilities' AND column IN ('#{disability_set}')".inspect
    disability = @session.execute("select * from lk_lookuptables where key='lk_Disabilities' AND column IN ('#{disability_set}')")
    disability.rows.each do |row|
      @final_disability = row["value"]
    end
    gender.rows.each do |row|
      @final_gender = row["value"]
    end
    ethnicity.rows.each do |row|
      @final_ethnicity = row["value"]
    end
    return @final_ethnicity, @final_gender, @final_disability
  end

end
