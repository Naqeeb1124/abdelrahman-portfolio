#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>
#include <map>
#include <limits>
#include <algorithm>
#include "Patient.h"
#include "Car.h"
#include "Hospital.h"

// Function to parse input file
std::tuple<int, std::map<std::string, int>, std::vector<std::vector<int>>, std::vector<std::vector<int>>, std::vector<Patient*>, std::vector<std::map<std::string, int>>> parse_input_file(const std::string& filepath) {
    std::ifstream f(filepath);
    std::string line;
    int H;
    std::map<std::string, int> car_speeds;
    std::vector<std::vector<int>> distance_matrix;
    std::vector<std::vector<int>> hospital_car_counts;
    std::vector<Patient*> patient_requests;
    std::vector<std::map<std::string, int>> cancellation_requests;

    // H, number of hospitals
    std::getline(f, line);
    H = std::stoi(line);

    // Car speeds
    std::getline(f, line);
    std::stringstream ss_speeds(line);
    int sc_speed, nc_speed;
    ss_speeds >> sc_speed >> nc_speed;
    car_speeds["SC"] = sc_speed;
    car_speeds["NC"] = nc_speed;

    // Distance matrix
    for (int i = 0; i < H; ++i) {
        std::getline(f, line);
        std::stringstream ss_dist(line);
        std::vector<int> row;
        int dist;
        while (ss_dist >> dist) {
            row.push_back(dist);
        }
        distance_matrix.push_back(row);
    }

    // Hospital car counts
    for (int i = 0; i < H; ++i) {
        std::getline(f, line);
        std::stringstream ss_counts(line);
        std::vector<int> row;
        int count;
        while (ss_counts >> count) {
            row.push_back(count);
        }
        hospital_car_counts.push_back(row);
    }

    // R, total number of requests
    int R;
    std::getline(f, line);
    R = std::stoi(line);

    // Patient requests
    for (int i = 0; i < R; ++i) {
        std::getline(f, line);
        std::stringstream ss_patient(line);
        std::string p_type_str;
        int qt, pid, hid, dst, svr = 0;
        ss_patient >> p_type_str >> qt >> pid >> hid >> dst;
        if (p_type_str == "EP") {
            ss_patient >> svr;
        }
        patient_requests.push_back(new Patient(p_type_str, qt, pid, hid, dst, svr));
    }

    // C, total number of cancellations
    int C;
    std::getline(f, line);
    C = std::stoi(line);

    // Cancellation requests
    for (int i = 0; i < C; ++i) {
        std::getline(f, line);
        std::stringstream ss_cancel(line);
        int ct, pid;
        ss_cancel >> ct >> pid;
        cancellation_requests.push_back({{"ct", ct}, {"pid", pid}});
    }

    f.close();
    return std::make_tuple(H, car_speeds, distance_matrix, hospital_car_counts, patient_requests, cancellation_requests);
}

// Function to run the simulation
void run_simulation(const std::string& input_filepath, const std::string& output_filepath, const std::string& mode) {
    auto [H, car_speeds, distance_matrix, hospital_car_counts, patient_requests, cancellation_requests] = parse_input_file(input_filepath);

    std::map<int, Hospital*> hospitals;
    for (int i = 0; i < H; ++i) {
        int hid = i + 1;
        int sc_num = hospital_car_counts[i][0];
        int nc_num = hospital_car_counts[i][1];
        hospitals[hid] = new Hospital(hid, sc_num, nc_num, car_speeds);
    }

    int current_time = 1;
    std::vector<Patient*> finished_patients;
    int total_simulation_time = 0;

    if (mode == "silent") {
        std::cout << "Silent Mode, Simulation Starts...\n";
    }

    while (true) {
        total_simulation_time = current_time;

        // Add new patient requests at current_time
        for (Patient* patient : patient_requests) {
            if (patient->qt == current_time) {
                hospitals[patient->hid]->add_patient_request(patient);
            }
        }

        // Handle cancellations
        for (const auto& cancel_req : cancellation_requests) {
            if (cancel_req.at("ct") == current_time) {
                for (auto const& [hid, hospital] : hospitals) {
                    if (hospital->cancel_np_request(cancel_req.at("pid"))) {
                        break;
                    }
                }
            }
        }

        // Assign cars and update car status for each hospital
        for (auto const& [hid, hospital] : hospitals) {
            hospital->assign_cars(current_time);
            hospital->update_car_status(current_time, finished_patients);
        }

        // EP patient re-assignment (Bonus)
        for (auto const& [hid, hospital] : hospitals) {
            if (hospital->get_ep_list_length() > 0) {
                // Simplified bonus logic: if an EP request is still in the queue,
                // try to reassign it to another hospital with the shortest EP list.
                // This is a basic implementation and can be improved.
                for (Patient* ep_patient : hospital->ep_requests) {
                    int original_hid = ep_patient->hid;
                    int shortest_ep_list_len = std::numeric_limits<int>::max();
                    int target_hid = -1;

                    for (auto const& [other_hid, other_hospital] : hospitals) {
                        if (other_hid != original_hid) {
                            int current_ep_list_len = other_hospital->get_ep_list_length();
                            if (current_ep_list_len < shortest_ep_list_len) {
                                shortest_ep_list_len = current_ep_list_len;
                                target_hid = other_hid;
                            } else if (current_ep_list_len == shortest_ep_list_len) {
                                // Tie-breaking: pick the one nearest to the current hospital
                                if (target_hid != -1 && distance_matrix[original_hid - 1][target_hid - 1] > distance_matrix[original_hid - 1][other_hid - 1]) {
                                    target_hid = other_hid;
                                }
                            }
                        }
                    }

                    if (target_hid != -1) {
                        Patient* patient_to_reassign = hospital->remove_ep_request(ep_patient->pid);
                        if (patient_to_reassign) {
                            patient_to_reassign->hid = target_hid;
                            hospitals[target_hid]->add_patient_request(patient_to_reassign);
                        }
                    }
                }
            }
        }

        if (mode == "interactive") {
            std::cout << "Current Timestep: " << current_time << "\n";
            for (auto const& [hid, hospital] : hospitals) {
                std::cout << "HOSPITAL #" << hid << " data\n";
                auto [ep_ids, sp_ids, np_ids] = hospital->get_patient_request_ids();
                std::cout << ep_ids.size() << " EP requests: ";
                for (int id : ep_ids) std::cout << id << ", ";
                std::cout << "\n";
                std::cout << sp_ids.size() << " SP requests: ";
                for (int id : sp_ids) std::cout << id << ", ";
                std::cout << "\n";
                std::cout << np_ids.size() << " NP requests: ";
                for (int id : np_ids) std::cout << id << ", ";
                std::cout << "\n";
                auto [free_sc, free_nc] = hospital->get_free_cars_count();
                std::cout << "Free Cars: " << free_sc << " SCars, " << free_nc << " NCars\n";
                std::cout << "HOSPITAL #" << hid << " data end\n";

                std::vector<std::string> out_cars;
                std::vector<std::string> back_cars;
                for (Car* car : hospital->assigned_cars) {
                    std::string car_id_part = car->car_id.substr(car->c_type.length() + 1);
                    out_cars.push_back(car->c_type + car_id_part.substr(0, car_id_part.find('_')) + "_H" + std::to_string(car->hospital_id) + "_P" + std::to_string(car->current_patient->pid));
                }
                for (Car* car : hospital->loaded_cars) {
                    std::string car_id_part = car->car_id.substr(car->c_type.length() + 1);
                    back_cars.push_back(car->c_type + car_id_part.substr(0, car_id_part.find('_')) + "_H" + std::to_string(car->hospital_id) + "_P" + std::to_string(car->current_patient->pid));
                }

                if (!out_cars.empty()) {
                    std::cout << out_cars.size() << " ==> Out cars: ";
                    for (const std::string& s : out_cars) std::cout << s << ", ";
                    std::cout << "\n";
                }
                if (!back_cars.empty()) {
                    std::cout << back_cars.size() << " <== Back cars: ";
                    for (const std::string& s : back_cars) std::cout << s << ", ";
                    std::cout << "\n";
                }
            }

            std::vector<int> finished_pids_current_time;
            for (Patient* p : finished_patients) {
                if (p->ft == current_time) {
                    finished_pids_current_time.push_back(p->pid);
                }
            }
            if (!finished_pids_current_time.empty()) {
                std::cout << finished_pids_current_time.size() << " finished patients: ";
                for (int id : finished_pids_current_time) std::cout << id << ", ";
                std::cout << "\n";
            }

            std::cout << "Press any key to display next hospital\n";
            std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
        }

        bool all_patients_processed = true;
        for (Patient* p : patient_requests) {
            if (p->ft == 0) {
                all_patients_processed = false;
                break;
            }
        }

        bool all_cars_free = true;
        for (auto const& [hid, hospital] : hospitals) {
            if (!hospital->assigned_cars.empty() || !hospital->loaded_cars.empty()) {
                all_cars_free = false;
                break;
            }
        }

        bool all_queues_empty = true;
        for (auto const& [hid, hospital] : hospitals) {
            if (!hospital->ep_requests.empty() || !hospital->sp_requests.empty() || !hospital->np_requests.empty()) {
                all_queues_empty = false;
                break;
            }
        }

        bool no_new_requests_or_cancellations = true;
        for (Patient* p : patient_requests) {
            if (p->qt == current_time) {
                no_new_requests_or_cancellations = false;
                break;
            }
        }
        for (const auto& cancel_req : cancellation_requests) {
            if (cancel_req.at("ct") == current_time) {
                no_new_requests_or_cancellations = false;
                break;
            }
        }

        if (all_patients_processed && all_cars_free && all_queues_empty && no_new_requests_or_cancellations) {
            break;
        }

        current_time++;
    }

    // Generate output file
    std::ofstream of(output_filepath);
    for (Patient* patient : finished_patients) {
        of << "FT: " << patient->ft << " PID: " << patient->pid << " QT: " << patient->qt << " WT: " << patient->wt << "\n";
    }

    int total_patients = patient_requests.size();
    int np_count = 0;
    int sp_count = 0;
    int ep_count = 0;
    for (Patient* p : patient_requests) {
        if (p->p_type == "NP") np_count++;
        else if (p->p_type == "SP") sp_count++;
        else if (p->p_type == "EP") ep_count++;
    }

    of << "\npatients: " << total_patients << " [NP: " << np_count << ", SP: " << sp_count << ", EP: " << ep_count << "]\n";
    of << "Hospitals = " << H << "\n";

    int total_cars = 0;
    int sc_cars_count = 0;
    int nc_cars_count = 0;
    long long total_busy_time = 0;

    for (auto const& [hid, hospital] : hospitals) {
        total_cars += hospital->free_sc_cars.size() + hospital->free_nc_cars.size() + hospital->assigned_cars.size() + hospital->loaded_cars.size();
        sc_cars_count += hospital->free_sc_cars.size();
        for (Car* car : hospital->assigned_cars) if (car->c_type == "SC") sc_cars_count++;
        for (Car* car : hospital->loaded_cars) if (car->c_type == "SC") sc_cars_count++;

        nc_cars_count += hospital->free_nc_cars.size();
        for (Car* car : hospital->assigned_cars) if (car->c_type == "NC") nc_cars_count++;
        for (Car* car : hospital->loaded_cars) if (car->c_type == "NC") nc_cars_count++;

        for (Car* car : hospital->free_sc_cars) total_busy_time += car->busy_time;
        for (Car* car : hospital->free_nc_cars) total_busy_time += car->busy_time;
        for (Car* car : hospital->assigned_cars) total_busy_time += car->busy_time;
        for (Car* car : hospital->loaded_cars) total_busy_time += car->busy_time;
    }

    of << "cars: " << total_cars << " [SCar: " << sc_cars_count << ", NCar: " << nc_cars_count << "]\n";

    double avg_wait_time = 0;
    if (!finished_patients.empty()) {
        long long total_wait_time = 0;
        for (Patient* p : finished_patients) total_wait_time += p->wt;
        avg_wait_time = static_cast<double>(total_wait_time) / finished_patients.size();
    }
    of << "Avg wait time = " << static_cast<int>(avg_wait_time) << "\n";

    double avg_busy_time = 0;
    if (total_cars > 0) {
        avg_busy_time = static_cast<double>(total_busy_time) / total_cars;
    }
    of << "Avg busy time = " << static_cast<int>(avg_busy_time) << "\n";

    double avg_utilization = 0;
    if (total_simulation_time > 0) {
        avg_utilization = (avg_busy_time / total_simulation_time) * 100;
    }
    of << "Avg utilization = " << static_cast<int>(avg_utilization) << "%\n";

    of.close();

    if (mode == "silent") {
        std::cout << "Simulation ends, Output file created\n";
    }

    // Clean up dynamically allocated memory
    for (Patient* p : patient_requests) {
        delete p;
    }
    for (auto const& [hid, hospital] : hospitals) {
        delete hospital;
    }
}

int main() {
    std::string user_mode;
    while (true) {
        std::cout << "Select mode (interactive/silent): ";
        std::cin >> user_mode;
        if (user_mode == "interactive" || user_mode == "silent") {
            break;
        } else {
            std::cout << "Invalid mode. Please enter 'interactive' or 'silent'.\n";
        }
    }

    std::string input_file = "input.txt";
    std::string output_file = "output.txt";

    run_simulation(input_file, output_file, user_mode);

    return 0;
}


