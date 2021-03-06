require_relative 'database_connection'
require 'date'
class Booking

  attr_reader :id, :listing_id, :user_id, :price_total
  attr_accessor :start_date, :end_date, :confirmation

  def initialize(id:, listing_id:, user_id:, start_date:, end_date:, price_total:, confirmation:)
    @id = id
    @listing_id = listing_id
    @user_id = user_id
    @start_date = start_date
    @end_date = end_date
    @price_total = price_total
    @confirmation = confirmation
  end

  def self.create(listing_id:, user_id:, start_date:, end_date:, price:, confirmation:)
    price_total = (Date.parse(end_date).mjd - Date.parse(start_date).mjd) * price
    result = DatabaseConnection.query("INSERT INTO bookings(listing_id, user_id, start_date, end_date, price_total, confirmation) VALUES(#{listing_id}, #{user_id}, '#{start_date}', '#{end_date}', #{price_total}, #{confirmation}) RETURNING id, listing_id, user_id, start_date, end_date, price_total, confirmation;")
    Booking.new(id: result[0]['id'], listing_id: result[0]['listing_id'], user_id: result[0]['user_id'], start_date: result[0]['start_date'], end_date: result[0]['end_date'], price_total: result[0]['price_total'], confirmation: result[0]['confirmation'])
  end

  def self.find(id:)
    result = DatabaseConnection.query("SELECT * FROM bookings WHERE id = #{id};")
    Booking.new(id: result[0]['id'], listing_id: result[0]['listing_id'], user_id: result[0]['user_id'], start_date: result[0]['start_date'], end_date: result[0]['end_date'], price_total: result[0]['price_total'], confirmation: result[0]['confirmation'])
  end

  def self.all
    result = DatabaseConnection.query("SELECT * FROM bookings;")
    result.map do |booking|
      Booking.new(id: result[0]['id'], listing_id: result[0]['listing_id'], user_id: result[0]['user_id'], start_date: result[0]['start_date'], end_date: result[0]['end_date'], price_total: result[0]['price_total'], confirmation: result[0]['confirmation'])
    end
  end

  def self.get_unavailable_dates(listing_id:)
    unavailable_dates = []
    result = DatabaseConnection.query("SELECT * FROM bookings WHERE listing_id = #{listing_id};")
    result.each do |booking|
      dates = (Date.parse(booking['start_date'])..Date.parse(booking['end_date'])).to_a
      dates.each do |date|
        unavailable_dates << date.to_s
      end
    end
    return unavailable_dates
  end

end
