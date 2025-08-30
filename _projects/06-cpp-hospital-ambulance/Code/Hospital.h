#ifndef HOSPITAL_H
#define HOSPITAL_H

#include <vector>
#include <string>
#include <map>
#include <algorithm>
#include "Patient.h"
#include "Car.h"

class Hospital {
public:
    int hid;
    int sc_num;
    int nc_num;
    std::vector<Car*> free_sc_cars;
    std::vector<Car*> free_nc_cars;
    std::vector<Car*> assigned_cars;
    std::vector<Car*> loaded_cars;
    std::vector<Patient*> ep_requests;
    std::vector<Patient*> sp_requests;
    std::vector<Patient*> np_requests;

    Hospital(int hid, int sc_num, int nc_num, const std::map<std::string, int>& car_speeds);
    ~Hospital();

    void add_patient_request(Patient* patient);
    void assign_cars(int current_time);
    void update_car_status(int current_time, std::vector<Patient*>& finished_patients);
    std::pair<int, int> get_free_cars_count();
    std::tuple<std::vector<int>, std::vector<int>, std::vector<int>> get_patient_request_ids();
    bool cancel_np_request(int pid);
    int get_ep_list_length();
    Patient* remove_ep_request(int pid);
};

#endif // HOSPITAL_H


