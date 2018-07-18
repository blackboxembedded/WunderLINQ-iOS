//
//  Faults.swift
//  WunderLINQ
//
//  Created by Keith Conger on 7/13/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import Foundation

class Faults {
    static let shared = Faults()

    // UART Faults
    var uartErrorActive: Bool = false
    let uartErrorDesc: String = NSLocalizedString("UART Error", comment: "")
    func setUartErrorActive(active: Bool?){
        self.uartErrorActive = active!
    }
    func getUartErrorActive() -> Bool{
        return self.uartErrorActive
    }
    
    var uartCommActive: Bool = false
    var uartCommDesc: String = NSLocalizedString("UART Comm Timeout", comment: "")
    func setUartCommActive(active: Bool?){
        self.uartCommActive = active!
    }
    func getUartCommActive() -> Bool{
        return self.uartCommActive
    }
    
    // Motorcycle faults
    var absSelfDiagActive: Bool = false
    var absSelfDiagDesc: String = NSLocalizedString("ABS self-diagnosis not completed", comment: "")
    func setAbsSelfDiagActive(active: Bool?){
        self.absSelfDiagActive = active!
    }
    func getAbsSelfDiagActive() -> Bool{
        return self.absSelfDiagActive
    }
    
    var absDeactivatedActive: Bool = false
    var absDeactivatedDesc: String = NSLocalizedString("ABS deactivated", comment: "")
    func setAbsDeactivatedActive(active: Bool?){
        self.absDeactivatedActive = active!
    }
    func getAbsDeactivatedActive() -> Bool{
        return self.absDeactivatedActive
    }
    
    var absErrorActive: Bool = false
    var absErrorDesc: String = NSLocalizedString("ABS error", comment: "")
    func setAbsErrorActive(active: Bool?){
        self.absErrorActive = active!
    }
    func getAbsErrorActive() -> Bool{
        return self.absErrorActive
    }
    
    var ascSelfDiagActive: Bool = false
    var ascSelfDiagDesc: String = NSLocalizedString("ASC self-diagnosis not completed", comment: "")
    func setAscSelfDiagActive(active: Bool?){
        self.ascSelfDiagActive = active!
    }
    func getAscSelfDiagActive() -> Bool{
        return self.ascSelfDiagActive
    }
    
    var ascInterventionActive: Bool = false
    var ascInterventionDesc: String = NSLocalizedString("ASC intervention", comment: "")
    func setAscInterventionActive(active: Bool?){
        self.ascInterventionActive = active!
    }
    func getAscInterventionActive() -> Bool{
        return self.ascInterventionActive
    }
    
    var ascDeactivatedActive: Bool = false
    var ascDeactivatedDesc: String = NSLocalizedString("ASC deactivated", comment: "")
    func setAscDeactivatedActive(active: Bool?){
        self.ascDeactivatedActive = active!
    }
    func getAscDeactivatedActive() -> Bool{
        return self.ascDeactivatedActive
    }
    
    var ascErrorActive: Bool = false
    var ascErrorDesc: String = NSLocalizedString("ASC error", comment: "")
    func setAscErrorActive(active: Bool?){
        self.ascErrorActive = active!
    }
    func getAscErrorActive() -> Bool{
        return self.ascErrorActive
    }
    
    var fuelFaultActive: Bool = false
    var fuelFaultDesc: String = NSLocalizedString("Low Fuel", comment: "")
    func setFuelFaultActive(active: Bool?){
        self.fuelFaultActive = active!
    }
    func getFuelFaultActive() -> Bool{
        return self.fuelFaultActive
    }
    
    var frontTirePressureWarningActive: Bool = false
    var frontTirePressureWarningDesc: String = NSLocalizedString("Front Tire Pressure Warning", comment: "")
    func setFrontTirePressureWarningActive(active: Bool?){
        self.frontTirePressureWarningActive = active!
    }
    func getFrontTirePressureWarningActive() -> Bool{
        return self.frontTirePressureWarningActive
    }
    
    var rearTirePressureWarningActive: Bool = false
    var rearTirePressureWarningDesc: String = NSLocalizedString("Rear Tire Pressure Warning", comment: "")
    func setRearTirePressureWarningActive(active: Bool?){
        self.rearTirePressureWarningActive = active!
    }
    func getRearTirePressureWarningActive() -> Bool{
        return self.rearTirePressureWarningActive
    }
    
    var frontTirePressureCriticalNotificationActive: Bool = false
    var frontTirePressureCriticalActive: Bool = false
    var frontTirePressureCriticalDesc: String = NSLocalizedString("Front Tire Pressure Critical", comment: "")
    func setFrontTirePressureCriticalActive(active: Bool?){
        self.frontTirePressureCriticalActive = active!
    }
    func getFrontTirePressureCriticalActive() -> Bool{
        return self.frontTirePressureCriticalActive
    }
    
    var rearTirePressureCriticalNotificationActive: Bool = false
    var rearTirePressureCriticalActive: Bool = false
    var rearTirePressureCriticalDesc: String = NSLocalizedString("Rear Tire Pressure Critical", comment: "")
    func setRearTirePressureCriticalActive(active: Bool?){
        self.rearTirePressureCriticalActive = active!
    }
    func getRearTirePressureCriticalActive() -> Bool{
        return self.rearTirePressureCriticalActive
    }
    
    var addFrontLightOneActive: Bool = false
    var addFrontLightOneDesc: String = NSLocalizedString("Additional front light 1", comment: "")
    func setAddFrontLightOneActive(active: Bool?){
        self.addFrontLightOneActive = active!
    }
    func getAddFrontLightOneActive() -> Bool{
        return self.addFrontLightOneActive
    }
    
    var addFrontLightTwoActive: Bool = false
    var addFrontLightTwoDesc: String = NSLocalizedString("Additional front light 2", comment: "")
    func setAddFrontLightTwoActive(active: Bool?){
        self.addFrontLightTwoActive = active!
    }
    func getAddFrontLightTwoActive() -> Bool{
        return self.addFrontLightTwoActive
    }
    
    var daytimeRunningActive: Bool = false
    var daytimeRunningDesc: String = NSLocalizedString("Daytime running light", comment: "")
    func setDaytimeRunningActive(active: Bool?){
        self.daytimeRunningActive = active!
    }
    func getDaytimeRunningActive() -> Bool{
        return self.daytimeRunningActive
    }
    
    var frontLeftSignalActive: Bool = false
    var frontLeftSignalDesc: String = NSLocalizedString("Front left indicator", comment: "")
    func setFrontLeftSignalActive(active: Bool?){
        self.frontLeftSignalActive = active!
    }
    func getFrontLeftSignalActive() -> Bool{
        return self.frontLeftSignalActive
    }
    
    var frontRightSignalActive: Bool = false
    var frontRightSignalDesc: String = NSLocalizedString("Front right indicator", comment: "")
    func setFrontRightSignalActive(active: Bool?){
        self.frontRightSignalActive = active!
    }
    func getFrontRightSignalActive() -> Bool{
        return self.frontRightSignalActive
    }
    
    var rearLeftSignalActive: Bool = false
    var rearLeftSignalDesc: String = NSLocalizedString("Rear left indicator", comment: "")
    func setRearLeftSignalActive(active: Bool?){
        self.rearLeftSignalActive = active!
    }
    func getRearLeftSignalActive() -> Bool{
        return self.rearLeftSignalActive
    }
    
    var rearRightSignalActive: Bool = false
    var rearRightSignalDesc: String = NSLocalizedString("Rear right indicator", comment: "")
    func setRearRightSignalActive(active: Bool?){
        self.rearRightSignalActive = active!
    }
    func getRearRightSignalActive() -> Bool{
        return self.rearRightSignalActive
    }
    
    var frontParkingLightOneActive: Bool = false
    var frontParkingLightOneDesc: String = NSLocalizedString("Front parking light 1", comment: "")
    func setFrontParkingLightOneActive(active: Bool?){
        self.frontParkingLightOneActive = active!
    }
    func getFrontParkingLightOneActive() -> Bool{
        return self.frontParkingLightOneActive
    }
    
    var frontParkingLightTwoActive: Bool = false
    var frontParkingLightTwoDesc: String = NSLocalizedString("Front parking light 2", comment: "")
    func setFrontParkingLightTwoActive(active: Bool?){
        self.frontParkingLightTwoActive = active!
    }
    func getFrontParkingLightTwoActive() -> Bool{
        return self.frontParkingLightTwoActive
    }
    
    var lowBeamActive: Bool = false
    var lowBeamDesc: String = NSLocalizedString("Low-beam", comment: "")
    func setLowBeamActive(active: Bool?){
        self.lowBeamActive = active!
    }
    func getLowBeamActive() -> Bool{
        return self.lowBeamActive
    }
    
    var highBeamActive: Bool = false
    var highBeamDesc: String = NSLocalizedString("High-beam", comment: "")
    func setHighBeamActive(active: Bool?){
        self.highBeamActive = active!
    }
    func getHighBeamActive() -> Bool{
        return self.highBeamActive
    }
    
    var rearLightActive: Bool = false
    var rearLightDesc: String = NSLocalizedString("Rear Light", comment: "")
    func setRearLightActive(active: Bool?){
        self.rearLightActive = active!
    }
    func getRearLightActive() -> Bool{
        return self.rearLightActive
    }
    
    var brakeLightActive: Bool = false
    var brakeLightDesc: String = NSLocalizedString("Brake Light", comment: "")
    func setBrakeLightActive(active: Bool?){
        self.brakeLightActive = active!
    }
    func getBrakeLightActive() -> Bool{
        return self.brakeLightActive
    }
    
    var licenseLightActive: Bool = false
    var licenseLightDesc: String = NSLocalizedString("License plate Light", comment: "")
    func setLicenseLightActive(active: Bool?){
        self.licenseLightActive = active!
    }
    func getLicenseLightActive() -> Bool{
        return self.licenseLightActive
    }
    
    var rearFogLightActive: Bool = false
    var rearFogLightDesc: String = NSLocalizedString("Rear Fog Light", comment: "")
    func setRearFogLightActive(active: Bool?){
        self.rearFogLightActive = active!
    }
    func getRearFogActive() -> Bool{
        return self.rearFogLightActive
    }
    
    var addDippedLightActive: Bool = false
    var addDippedLightDesc: String = NSLocalizedString("Additional dipped/high-beam", comment: "")
    func setAddDippedLightActive(active: Bool?){
        self.addDippedLightActive = active!
    }
    func getAddDippedActive() -> Bool{
        return self.addDippedLightActive
    }
    
    var addBrakeLightActive: Bool = false
    var addBrakeLightDesc: String = NSLocalizedString("Additional brake light", comment: "")
    func setAddBrakeLightActive(active: Bool?){
        self.addBrakeLightActive = active!
    }
    func getAddBrakeActive() -> Bool{
        return self.addBrakeLightActive
    }
    
    var frontLampOneLightActive: Bool = false
    var frontLampOneLightDesc: String = NSLocalizedString("Front lamp 1", comment: "")
    func setFrontLampOneLightActive(active: Bool?){
        self.frontLampOneLightActive = active!
    }
    func getFrontLampOneLightActive() -> Bool{
        return self.frontLampOneLightActive
    }
    
    var frontLampTwoLightActive: Bool = false
    var frontLampTwoLightDesc: String = NSLocalizedString("Front lamp 2", comment: "")
    func setFrontLampTwoLightActive(active: Bool?){
        self.frontLampTwoLightActive = active!
    }
    func getFrontLampTwoLightActive() -> Bool{
        return self.frontLampTwoLightActive
    }
    
    var iceWarningActive: Bool = false
    var iceWarningDesc: String = NSLocalizedString("Ice Warning", comment: "")
    func setIceWarningActive(active: Bool?){
        self.iceWarningActive = active!
    }
    func getIceWarningActive() -> Bool{
        return self.iceWarningActive
    }
    
    var generalFlashingYellowActive: Bool = false
    var generalFlashingYellowDesc: String = NSLocalizedString("The general warning light flashes yellow", comment: "")
    func setGeneralFlashingYellowActive(active: Bool?){
        self.generalFlashingYellowActive = active!
    }
    func getGeneralFlashingYellowActive() -> Bool{
        return self.generalFlashingYellowActive
    }
    
    var generalShowsYellowActive: Bool = false
    var generalShowsYellowDesc: String = NSLocalizedString("The general warning light shows yellow", comment: "")
    func setGeneralShowsYellowActive(active: Bool?){
        self.generalShowsYellowActive = active!
    }
    func getGeneralShowsYellowActive() -> Bool{
        return self.generalShowsYellowActive
    }
    
    var generalFlashingRedNotificationActive: Bool = false
    var generalFlashingRedActive: Bool = false
    var generalFlashingRedDesc: String = NSLocalizedString("The general warning light flashes red", comment: "")
    func setGeneralFlashingRedActive(active: Bool?){
        self.generalFlashingRedActive = active!
    }
    func getGeneralFlashingRedActive() -> Bool{
        return self.generalFlashingRedActive
    }
    
    var generalShowsRedNotificationActive: Bool = false
    var generalShowsRedActive: Bool = false
    var generalShowsRedDesc: String = NSLocalizedString("The general warning light shows red", comment: "")
    func setGeneralShowsRedActive(active: Bool?){
        self.generalShowsRedActive = active!
    }
    func getGeneralShowsRedActive() -> Bool{
        return self.generalShowsRedActive
    }
    
    var oilLowActive: Bool = false
    var oilLowDesc: String = NSLocalizedString("Engine oil level too low", comment: "")
    func setOilLowActive(active: Bool?){
        self.oilLowActive = active!
    }
    func getOilLowActive() -> Bool{
        return self.oilLowActive
    }

    func getallActiveDesc() ->[String]{
        var allActiveDesc = [String]()
        // Debug faults
        if(uartErrorActive){
            allActiveDesc.append(uartErrorDesc)
        }
        if(uartCommActive){
            allActiveDesc.append(uartCommDesc)
        }
        
        // Motorcycle faults
        if(absSelfDiagActive){
            allActiveDesc.append(absSelfDiagDesc);
        }
        if(absDeactivatedActive){
            allActiveDesc.append(absDeactivatedDesc);
        }
        if(absErrorActive){
            allActiveDesc.append(absErrorDesc);
        }
        if(ascSelfDiagActive){
            allActiveDesc.append(ascSelfDiagDesc);
        }
        if(ascInterventionActive){
            allActiveDesc.append(ascInterventionDesc);
        }
        if(ascDeactivatedActive){
            allActiveDesc.append(ascDeactivatedDesc);
        }
        if(ascErrorActive){
            allActiveDesc.append(ascErrorDesc);
        }
        if(fuelFaultActive){
            allActiveDesc.append(fuelFaultDesc);
        }
        if(frontTirePressureWarningActive){
            allActiveDesc.append(frontTirePressureWarningDesc);
        }
        if(rearTirePressureWarningActive){
            allActiveDesc.append(rearTirePressureWarningDesc);
        }
        if(frontTirePressureCriticalActive){
            allActiveDesc.append(frontTirePressureCriticalDesc);
        }
        if(rearTirePressureCriticalActive){
            allActiveDesc.append(rearTirePressureCriticalDesc);
        }
        if(addFrontLightOneActive){
            allActiveDesc.append(addFrontLightOneDesc);
        }
        if(addFrontLightTwoActive){
            allActiveDesc.append(addFrontLightTwoDesc);
        }
        if(daytimeRunningActive){
            allActiveDesc.append(daytimeRunningDesc);
        }
        if(frontLeftSignalActive){
            allActiveDesc.append(frontLeftSignalDesc);
        }
        if(frontRightSignalActive){
            allActiveDesc.append(frontRightSignalDesc);
        }
        if(rearLeftSignalActive){
            allActiveDesc.append(rearLeftSignalDesc);
        }
        if(rearRightSignalActive){
            allActiveDesc.append(rearRightSignalDesc);
        }
        if(frontParkingLightOneActive){
            allActiveDesc.append(frontParkingLightOneDesc);
        }
        if(frontParkingLightTwoActive){
            allActiveDesc.append(frontParkingLightTwoDesc);
        }
        if(lowBeamActive){
            allActiveDesc.append(lowBeamDesc);
        }
        if(highBeamActive){
            allActiveDesc.append(highBeamDesc);
        }
        if(rearLightActive){
            allActiveDesc.append(rearLightDesc);
        }
        if(brakeLightActive){
            allActiveDesc.append(brakeLightDesc);
        }
        if(licenseLightActive){
            allActiveDesc.append(licenseLightDesc);
        }
        if(rearFogLightActive){
            allActiveDesc.append(rearFogLightDesc);
        }
        if(addDippedLightActive){
            allActiveDesc.append(addDippedLightDesc);
        }
        if(addBrakeLightActive){
            allActiveDesc.append(addBrakeLightDesc);
        }
        if(frontLampOneLightActive){
            allActiveDesc.append(frontLampOneLightDesc);
        }
        if(frontLampTwoLightActive){
            allActiveDesc.append(frontLampTwoLightDesc);
        }
        if(iceWarningActive){
            allActiveDesc.append(iceWarningDesc);
        }
        if(generalFlashingYellowActive){
            allActiveDesc.append(generalFlashingYellowDesc);
        }
        if(generalShowsYellowActive){
            allActiveDesc.append(generalShowsYellowDesc);
        }
        if(generalFlashingRedActive){
            allActiveDesc.append(generalFlashingRedDesc);
        }
        if(generalShowsRedActive){
            allActiveDesc.append(generalShowsRedDesc);
        }
        if(oilLowActive){
            allActiveDesc.append(oilLowDesc);
        }
        
        return allActiveDesc
    }

}
