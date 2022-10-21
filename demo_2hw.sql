-- 1. Вывести список самолетов в порядке убывания количества мест
SELECT model, count(seat_no) FROM aircrafts air
JOIN seats s ON air.aircraft_code = s.aircraft_code
GROUP BY air.model
ORDER BY count(seat_no) DESC;

-- 2. Вывести список самолетов в порядке возрастания соотношения количества мест бизнес-класса 
--    к количеству мест эконом-класса
SELECT tbl1.model, economy_count, business_count FROM
(SELECT model, count(seat_no) as economy_count FROM aircrafts air
JOIN seats s ON air.aircraft_code = s.aircraft_code
WHERE s.fare_conditions = 'Economy'
GROUP BY air.model) tbl1
FULL JOIN
(SELECT model, count(seat_no) as business_count FROM aircrafts air
JOIN seats s ON air.aircraft_code = s.aircraft_code
WHERE s.fare_conditions = 'Business'
GROUP BY air.model) tbl2
ON tbl1.model = tbl2.model
ORDER BY economy_count / business_count;

-- 3. Вывести список самолетов в порядке убывания количества полетов
SELECT air.model, count(flight_no) as f_c FROM aircrafts air
JOIN flights f ON air.aircraft_code = f.aircraft_code
GROUP BY air.model
ORDER BY f_c DESC;

-- 4. Вывести список самолетов со средним временем продолжительности полета каждого
SELECT air.model, avg(actual_arrival - actual_departure) FROM aircrafts air
LEFT JOIN flights f ON air.aircraft_code = f.aircraft_code
GROUP BY air.model;

-- 5. Вывести среднее время задержки вылета в каждом аэропорту
SELECT air.airport_name, avg(f.actual_departure - f.scheduled_departure) FROM airports air
JOIN flights f ON air.airport_code = f.departure_airport
GROUP BY air.airport_name;

-- 6. Вывести наименьшее и наибольшее суммарное время задержки вылета в каждом аэропорту
SELECT min(sum_time), max(sum_time) FROM (SELECT air.airport_name, sum(f.actual_departure - f.scheduled_departure) as sum_time FROM airports air
JOIN flights f ON air.airport_code = f.departure_airport
GROUP BY air.airport_name) tbl;

-- 7. Вывести количество бронирований вылета из Москвы (доступ к значению города из JSON объекта airport_name -> 'ru' )
SELECT count(b.book_ref) FROM airports air
JOIN flights f ON air.airport_code = f.departure_airport
JOIN ticket_flights tf ON f.flight_id = tf.flight_id
JOIN tickets t ON t.ticket_no = tf.ticket_no
JOIN bookings b ON b.book_ref = t.book_ref
WHERE air.city = 'Москва';

-- 8. Вывести все полеты между городами в разных временных поясах за один день (любой)
SELECT tbl1.flight_id, tbl1.timezone, tbl2.timezone FROM
(SELECT flight_id, air.timezone FROM airports air
JOIN flights f ON air.airport_code = f.departure_airport
WHERE scheduled_departure::date = '2017-07-16') tbl1
JOIN
(SELECT flight_id, air.timezone FROM airports air
JOIN flights f ON air.airport_code = f.arrival_airport
WHERE scheduled_arrival::date = '2017-07-16') tbl2 ON tbl1.flight_id = tbl2.flight_id
WHERE tbl1.timezone != tbl2.timezone

-- 9. Вывести данные пассажиров и даты перелетов в/из Москвы у которых в номере паспорта есть сочетание 473
SELECT t.passenger_name, f.actual_departure, f.actual_arrival FROM airports air
JOIN flights f ON air.airport_code = f.arrival_airport or air.airport_code = f.departure_airport
JOIN ticket_flights tf ON f.flight_id = tf.flight_id
JOIN tickets t ON t.ticket_no = tf.ticket_no
WHERE air.city = 'Москва' and t.passenger_id like '%473%';

-- 10. Вывести всю информацию по конкретному бронированию (код бронирования, дата, сумма, номера билетов, имя, 
--     паспорт пассажиров, время вылета, аэропорт вылета, время прилета, аэропорт прилета, модель самолета). 
--     Код бронирования выбрать любой.
SELECT b.book_ref, b.book_date, b.total_amount, t.ticket_no, t.passenger_name, t.passenger_id, f.scheduled_departure, 
f.departure_airport, f.scheduled_arrival, f.arrival_airport, air.model FROM aircrafts air
JOIN flights f ON air.aircraft_code = f.aircraft_code
JOIN ticket_flights tf ON f.flight_id = tf.flight_id
JOIN tickets t ON t.ticket_no = tf.ticket_no
JOIN bookings b ON b.book_ref = t.book_ref
WHERE b.book_ref = '000068';
