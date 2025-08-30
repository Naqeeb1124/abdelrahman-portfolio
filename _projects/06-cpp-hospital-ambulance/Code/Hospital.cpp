#include "Hospital.h"

Hospital::Hospital(int hid, int sc_num, int nc_num, const std::map<std::string, int>& car_speeds) {
    this->hid = hid;
    this->sc_num = sc_num;
    this->nc_num = nc_num;

    for (int i = 0; i < sc_num; ++i) {
        free_sc_cars.push_back(new Car("SC", car_speeds.at("SC"), "SC_" + std::to_string(hid) + "_" + std::to_string(i + 1), hid));
    }
    for (int i = 0; i < nc_num; ++i) {
        free_nc_cars.push_back(new Car("NC", car_speeds.at("NC"), "NC_" + std::to_string(hid) + "_" + std::to_string(i + 1), hid));
    }
}

Hospital::~Hospital() {
    for (Car* car : free_sc_cars) delete car;
    for (Car* car : free_nc_cars) delete car;
    for (Car* car : assigned_cars) delete car;
    for (Car* car : loaded_cars) delete car;
    for (Patient* patient : ep_requests) delete patient;
    for (Patient* patient : sp_requests) delete patient;
    for (Patient* patient : np_requests) delete patient;
}

void Hospital::add_patient_request(Patient* patient) {
    if (patient->p_type == "EP") {
        ep_requests.push_back(patient);
        std::sort(ep_requests.begin(), ep_requests.end(), [](Patient* a, Patient* b) {
            return a->svr > b->svr;
        });
    } else if (patient->p_type == "SP") {
        sp_requests.push_back(patient);
    } else if (patient->p_type == "NP") {
        np_requests.push_back(patient);
    }
}

void Hospital::assign_cars(int current_time) {
    std::vector<Patient*> ep_assigned;
    for (Patient* patient : ep_requests) {
        bool assigned = false;
        if (!free_nc_cars.empty()) {
            Car* car = free_nc_cars[0];
            free_nc_cars.erase(free_nc_cars.begin());
            car->assign_patient(patient);
            patient->at = current_time;
            patient->car_id = car->car_id;
            assigned_cars.push_back(car);
            ep_assigned.push_back(patient);
            assigned = true;
        } else if (!free_sc_cars.empty()) {
            Car* car = free_sc_cars[0];
            free_sc_cars.erase(free_sc_cars.begin());
            car->assign_patient(patient);
            patient->at = current_time;
            patient->car_id = car->car_id;
            assigned_cars.push_back(car);
            ep_assigned.push_back(patient);
            assigned = true;
        }
        if (assigned) {
            break;
        }
    }
    for (Patient* p : ep_assigned) {
        ep_requests.erase(std::remove(ep_requests.begin(), ep_requests.end(), p), ep_requests.end());
    }

    std::vector<Patient*> sp_assigned;
    for (Patient* patient : sp_requests) {
        if (!free_sc_cars.empty()) {
            Car* car = free_sc_cars[0];
            free_sc_cars.erase(free_sc_cars.begin());
            car->assign_patient(patient);
            patient->at = current_time;
            patient->car_id = car->car_id;
            assigned_cars.push_back(car);
            sp_assigned.push_back(patient);
        } else {
            break;
        }
    }
    for (Patient* p : sp_assigned) {
        sp_requests.erase(std::remove(sp_requests.begin(), sp_requests.end(), p), sp_requests.end());
    }

    std::vector<Patient*> np_assigned;
    for (Patient* patient : np_requests) {
        if (!free_nc_cars.empty()) {
            Car* car = free_nc_cars[0];
            free_nc_cars.erase(free_nc_cars.begin());
            car->assign_patient(patient);
            patient->at = current_time;
            patient->car_id = car->car_id;
            assigned_cars.push_back(car);
            np_assigned.push_back(patient);
        } else {
            break;
        }
    }
    for (Patient* p : np_assigned) {
        np_requests.erase(std::remove(np_requests.begin(), np_requests.end(), p), np_requests.end());
    }
}

void Hospital::update_car_status(int current_time, std::vector<Patient*>& finished_patients) {
    std::vector<Car*> cars_to_move_to_loaded;
    for (Car* car : assigned_cars) {
        Patient* patient = car->current_patient;
        int time_to_reach_patient = patient->dst / car->speed;
        if (current_time >= patient->at + time_to_reach_patient) {
            car->pick_patient();
            patient->pt = current_time;
            patient->calculate_wt();
            cars_to_move_to_loaded.push_back(car);
        }
    }
    for (Car* car : cars_to_move_to_loaded) {
        assigned_cars.erase(std::remove(assigned_cars.begin(), assigned_cars.end(), car), assigned_cars.end());
        loaded_cars.push_back(car);
    }

    std::vector<Car*> cars_to_return_to_free;
    for (Car* car : loaded_cars) {
        Patient* patient = car->current_patient;
        int time_to_return_hospital = patient->dst / car->speed;
        if (current_time >= patient->pt + time_to_return_hospital) {
            patient->ft = current_time;
            patient->calculate_ft(car->speed);
            finished_patients.push_back(patient);
            car->return_to_hospital();
            if (car->c_type == "SC") {
                free_sc_cars.push_back(car);
            } else {
                free_nc_cars.push_back(car);
            }
            cars_to_return_to_free.push_back(car);
        }
    }
    for (Car* car : cars_to_return_to_free) {
        loaded_cars.erase(std::remove(loaded_cars.begin(), loaded_cars.end(), car), loaded_cars.end());
    }

    for (Car* car : assigned_cars) {
        car->busy_time++;
    }
    for (Car* car : loaded_cars) {
        car->busy_time++;
    }
}

std::pair<int, int> Hospital::get_free_cars_count() {
    return {free_sc_cars.size(), free_nc_cars.size()};
}

std::tuple<std::vector<int>, std::vector<int>, std::vector<int>> Hospital::get_patient_request_ids() {
    std::vector<int> ep_ids;
    for (Patient* p : ep_requests) ep_ids.push_back(p->pid);
    std::vector<int> sp_ids;
    for (Patient* p : sp_requests) sp_ids.push_back(p->pid);
    std::vector<int> np_ids;
    for (Patient* p : np_requests) np_ids.push_back(p->pid);
    return {ep_ids, sp_ids, np_ids};
}

bool Hospital::cancel_np_request(int pid) {
    Patient* patient_to_cancel = nullptr;
    auto it = np_requests.begin();
    while (it != np_requests.end()) {
        if ((*it)->pid == pid) {
            patient_to_cancel = *it;
            it = np_requests.erase(it);
            break;
        } else {
            ++it;
        }
    }

    if (patient_to_cancel) {
        for (Car* car : assigned_cars) {
            if (car->current_patient && car->current_patient->pid == pid) {
                car->return_to_hospital();
                if (car->c_type == "SC") {
                    free_sc_cars.push_back(car);
                } else {
                    free_nc_cars.push_back(car);
                }
                assigned_cars.erase(std::remove(assigned_cars.begin(), assigned_cars.end(), car), assigned_cars.end());
                break;
            }
        }
        delete patient_to_cancel;
        return true;
    }
    return false;
}

int Hospital::get_ep_list_length() {
    return ep_requests.size();
}

Patient* Hospital::remove_ep_request(int pid) {
    Patient* patient_to_remove = nullptr;
    auto it = ep_requests.begin();
    while (it != ep_requests.end()) {
        if ((*it)->pid == pid) {
            patient_to_remove = *it;
            it = ep_requests.erase(it);
            break;
        } else {
            ++it;
        }
    }
    return patient_to_remove;
}


