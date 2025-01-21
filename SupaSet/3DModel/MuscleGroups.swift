//
//  MuscleGroups.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/14/25.
//

//
//  MuscleGroups.swift
//  FinalProject
//
//  Created by Rishi Garg on 4/28/24.
//

import Foundation

struct MuscleGroups {
    static let muscleMappings: [MuscleGroup: [String]] = [
        .abdominals: ["Rectus_abdominis", "External_oblique", "Serratus_anterior"],
        .forearms: ["Brachioradialis", "Flexors", "Extensors", "Abductor_Pollicis_Longus"],
        .shoulders: ["Deltoid", "Infraspinatus", "Teres_major", "Teres_minor"],
        .biceps: ["Biceps_brachii", "Brachialis"],
        .chest: ["Pectoralis_major"],
        .lats: ["Latissimus_dorsi"],
        .lowerBack: ["Sacrum", "Spine", "Lumbar"],
        .neck: ["Sternocleidomastoid", "Neck", "Larynx"],
        .glutes: ["Gluteus_maximus", "Gluteus_medius"],
        .quadriceps: ["Quadriceps_femoris_-_Rectus", "Quadriceps_femoris_-_Vastus_medialis", "Quadriceps_femoris_-_Vastus_lateralis", "Patella"],
        .abductors: ["Tensor_fasciae_latae", "Iliotibial_tract"],
        .hamstrings: ["Semimembranosus_-_Semitendinosus", "Biceps_femoris"],
        .calves: ["Gastrocnemius", "Soleus"],
        .traps: ["Trapezius"],
        .triceps: ["Triceps_brachi_-_Long_and_Lateral_head6"],
//        .none: ["Hip_bone", "Humerus", "Radius", "Ulna", "Fibula", "Tibia", "Femur", "Scapula", "Clavicle", "Rib_cage", "Skull", "Simplified_Anatomy-_Male", "Feet", "Ears", "Nose", "Fibularis_longus", "Tibialis_anterior", "Extensor_digitorum_longus", "Adductors"]

//        .none: ["Brazoextra", "Garra", "Modelado_Musculos_Cuerpo_12_ZTL50DF832D_5F4A_494F_BFFB__13355e7", "Muslo10", "Muslo11", "Muslo12", "Pierna1", "Pierna4", "Pierna5", "Cara"]  // Including 'none' for muscles that aren't clearly categorized or are placeholders
    ]
    static func muscleForValue(_ value: String) -> MuscleGroup? {
            for (muscle, values) in muscleMappings {
                if values.contains(value) {
                    return muscle
                }
            }
            return nil // Return nil if the value is not found
        }
    static let locationMappings: [MuscleGroup: Int] = [
        //1 -> back, -1 -> front
        .abdominals: -1,
        .forearms: -1,
        .shoulders: 1,
        .biceps: -1,
        .chest: -1,
        .lats: 1,
        .lowerBack: 1,
        .neck: -1,
        .glutes: 1,
        .quadriceps: -1,
        .abductors: 1,  // Since abductors are located on the side of the thighs
        .hamstrings: 1,
        .calves: 1,
        .traps: 1,
        .triceps: 1
    ]
    
    // Method to get the location of a muscle group
    static func getLocation(of muscle: MuscleGroup) -> Int {
        return locationMappings[muscle] ?? 0
    }
}
