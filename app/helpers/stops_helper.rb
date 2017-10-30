module StopsHelper

  def date_format(date)
    if date.present?
      array_date = date.split('/')
      formatted_date = array_date[2]+'-'+array_date[0]+'-'+array_date[1]
    else
      formatted_date = "10-10-2018"
    end
  end

  def julian_day(date)
    array_date = date.split('/')
    year = array_date[2].to_i
    month = array_date[0].to_i
    date = array_date[1].to_i
    julian_day = Date.new(year, month, date).yday
  end

  def doj_record_id(date, total_records)
    increment_records = total_records + 1
    array_date = date.split('/')
    access_channel = "U"
    agency_ori = "1234567"
    last_two_date = array_date[2].last(2)
    julian = julian_day(Date.today.strftime("%m/%d/%y")).to_s
    sequence_number = "%07d" % [increment_records]
    doj_record_id = access_channel + agency_ori + last_two_date + julian + sequence_number
  end

end
