require_relative 'spec_helper'

ROOM_FILE = 'data/rooms.csv'
RESERVATION_FILE = 'data/reservations.csv'

describe 'BookingSystem' do
  describe 'initialize' do
    it 'is an instance of BookingSystem' do
      admin = Hotel::BookingSystem.new(ROOM_FILE, RESERVATION_FILE)
      expect(admin).must_be_kind_of Hotel::BookingSystem
    end

    it 'sets up data structures' do
      admin = Hotel::BookingSystem.new
      expect(admin.rooms).must_be_kind_of Array
      expect(admin.reservations).must_be_kind_of Array
    end
  end

  # before do
  #   rs1 = Hotel::Reservation.new(id: 102,
  #                                 guest_name: "Sam Pull",
  #                                 included_rooms: [2],
  #                                 rsv_start: "January 1, 2019",
  #                                 rsv_end: "January 10, 2019")
  #   rs2 = Hotel::Reservation.new(id: 103,
  #                                guest_name: "Bulldog Betty",
  #                                included_rooms: [19],
  #                                rsv_start: "October 22, 2019",
  #                                rsv_end: "October 25, 2019")
  #   rs3 = Hotel::Reservation.new(id: 104,
  #                                guest_name: "Dolly Raj",
  #                                included_rooms: [4, 7, 8],
  #                                rsv_start: "May 12, 2019",
  #                                rsv_end: "May 13, 2019")
  # end
  #
  describe 'it can find reservations by date' do
    let(:admin) do
      Hotel::BookingSystem.new
    end
    let(:finder) do
      x = Hotel::BookingSystem.new
      find_date = "October 22 2019"
      x.find_reservations_by_date(find_date)
    end
    it 'given a date, can find a reservation' do
      expect((finder).length).must_equal 3
    end
    it 'returns an array of reservations on that date' do
      expect(finder).must_be_kind_of Array
    end
    it 'returns an array of reservation instances' do
      expect(finder[0]).must_be_kind_of Hotel::Reservation
    end
    it 'returns empty array if no reservations found on that day' do
      find_date2 = "May 4 1337" # May 4 1337 used as test data for ensuring no reservations on that date"
      expect(admin.find_reservations_by_date(find_date2)).must_equal []
    end
    it 'given an id, can find a reservation' do
      id = 1
      expect(admin.find_a_reservation(id)).must_be_kind_of Hotel::Reservation
    end
    it 'raises an argument error if no reservation are found w/ that id' do
      id = 9999
      expect{ admin.find_a_reservation(id) }.must_raise ArgumentError
    end
    it 'can get total cost given a reservation id' do
      id = 2 # 1 room, 1 night, baserate 200.00
      expect(admin.get_reservation_total(id)).must_equal 1 * 1 * 200.00
      expect(admin.get_reservation_total(id)).must_be_kind_of Float
    end
    it 'can find available rooms given a check in and check out date' do
      check_in = "October 23 2019"
      check_out = "October 24 2019"
      expect(admin.find_available_rooms(check_in, check_out)).must_be_kind_of Array
      expect((admin.find_available_rooms(check_in, check_out)).length).must_equal 18
      check_in = "March 18 2022"
      check_out = "March 20 2022"
      expect((admin.find_available_rooms(check_in, check_out)).length).must_equal 20
    end
    it 'returns room as available when booked rsv_end date overlaps a start date for new reservation' do
      # id: 7,guest_name: Carolina Rivers,included_rooms: [5],rsv_start: March 13 2019, rsv_end: March 18 2019
      # id: 8,guest_name: Carp L Tunnel,included_rooms: [13],rsv_start: March 13 2019, rsv_end: March 21 2019
      check_in = "March 18 2019"
      check_out = "March 20 2019"
      expect(admin.find_available_rooms(check_in, check_out)).must_include 5
      expect(admin.find_available_rooms(check_in, check_out)).wont_include 13
    end

    it 'will not return a room where the rsv_start and rsv_end does not overlap with new reservation but other days in range overlap' do
      # id: 7,guest_name: Carolina Rivers,included_rooms: [5],rsv_start: March 13 2019, rsv_end: March 18 2019
      check_in = "March 12 2019"
      check_out = "March 19 2019"
      expect(admin.find_available_rooms(check_in, check_out)).wont_include 5
    end

    it 'will not return a room where any dates overlap' do
      # id: 7,guest_name: Carolina Rivers,included_rooms: [5],rsv_start: March 13 2019, rsv_end: March 18 2019
      check_in = "March 12 2019"
      check_out = "March 14 2019"
      expect(admin.find_available_rooms(check_in, check_out)).wont_include 5
      # id: 8,guest_name: Carp L Tunnel,included_rooms: [13],rsv_start: March 13 2019, rsv_end: March 21 2019
      check_in = "March 20 2019"
      check_out = "March 21 2019"
      expect(admin.find_available_rooms(check_in, check_out)).wont_include 13
    end
end

  describe 'it can create a reservation' do
    let(:admin) do
      Hotel::BookingSystem.new
    end

    it 'can create a new reservation' do
      guest = "Richardina Pardina"
      check_in = "March 18 2019"
      check_out = "March 20 2019"
      expect(admin.make_a_reservation(guest, check_in, check_out)).must_be_kind_of Hotel::Reservation
    end
    it 'defaults to a single room reservation' do
      guest = "test test"
      check_in = "September 3 2020"
      check_out = "September 4 2020"
      test = admin.make_a_reservation(guest, check_in, check_out)
      expect(test.included_rooms.length).must_equal 1
    end

    it 'can book more than one room in a single reservation' do
      guest = "test test"
      check_in = "September 3 2020"
      check_out = "September 4 2020"
      test = admin.make_a_reservation(guest, check_in, check_out, 5)
      expect(test.included_rooms.length).must_equal 5
    end

    it 'raises an error when the requested number of rooms is invalid' do
      guest = "test test"
      check_in = "September 3 2020"
      check_out = "September 4 2020"
      expect{admin.make_a_reservation(guest, check_in, check_out, 21)}.must_raise ArgumentError
      expect{admin.make_a_reservation(guest, check_in, check_out, 'test')}.must_raise ArgumentError
    end

    it 'increases the reservation id by 1 when a new reservation is added' do
      guest = 'Richardina Pardina'
      check_in = 'March 18 2019'
      check_out = 'March 20 2019'
      admin.make_a_reservation(guest, check_in, check_out)
      # binding.pry
      expect((admin.reservations.last).id).must_equal 9
    end

    it 'raises an argument error when no rooms are available' do
      guest = 'testing'
      check_in = 'September 3 2019'
      check_out = 'September 4 2019'
      # fill up the 20 room hotel with sept 3-4 bookings
      admin.make_a_reservation(guest, check_in, check_out, 20)

      expect{
        guest = 'testing'
        check_in = 'September 3 2019'
        check_out = 'September 4 2019'
        admin.make_a_reservation(guest, check_in, check_out)}.must_raise StandardError
    end
  end

  describe 'block bookings' do
    let(:admin) do
      Hotel::BookingSystem.new
    end

    it 'can create block bookings' do
      group_name = 'Block Testing'
      check_in = 'September 3 2019'
      check_out = 'September 4 2019'
      room_qty = 4
      status = :BLOCK
      @block = admin.make_a_block(group_name, check_in, check_out, room_qty, status)
      expect(@block).must_be_kind_of Hotel::BlockReservation
    end

    it 'can hold correct number of rooms' do
      group_name = 'Block Testing'
      check_in = 'September 3 2019'
      check_out = 'September 4 2019'
      room_qty = 4
      status = :BLOCK
      @block = admin.make_a_block(group_name, check_in, check_out, room_qty, status)
      expect((@block.included_rooms).length).must_equal 4
    end

    it 'can correctly calculate total cost for a block' do
      group_name = 'Block Testing'
      check_in = 'September 3 2019'
      check_out = 'September 4 2019'
      room_qty = 4
      status = :BLOCK
      @block = admin.make_a_block(group_name, check_in, check_out, room_qty, status)
      # binding.pry
      expect(@block.total_cost).must_be_close_to 640.00
    end
    it 'only includes available rooms for given date range' do
      group_name = 'Block Testing'
      check_in = 'December 1 2019'
      check_out = 'December 5 2019'
      room_qty = 4
      status = :BLOCK
      @block = admin.make_a_block(group_name, check_in, check_out, room_qty, status)
      # binding.pry
      expect(@block.included_rooms).wont_include 3
    end

    # TODO: make tests and methods to reserve a room within a block
    it 'can make a reservation within a block' do
      @rsv = admin.make_a_rsv_in_block('Johnson', 'Egan')
      expect(@rsv).must_be_kind_of Hotel::Reservation
      expect(@rsv.block_rsv[3]).must_equal 'Egan'
    end

    # it 'can make subsequent reservations within a block' do
    #   block_test = Hotel::BookingSystem.new
    #
    #   @rsv = block_test.make_a_rsv_in_block('Johnson', 'Senecal')
    #   expect(@rsv.block_rsv[3]).must_equal 'Senecal'
    #
    #   block_test.make_a_rsv_in_block('Johnson', 'Egan')
    #   expect(@rsv.block_rsv[4]).must_equal 'Egan'
    #   binding.pry
    #   block_test.make_a_rsv_in_block('Johnson', 'Allala')
    #   expect(@rsv.block_rsv[5]).must_equal 'Allala'
    # end
  end

end


