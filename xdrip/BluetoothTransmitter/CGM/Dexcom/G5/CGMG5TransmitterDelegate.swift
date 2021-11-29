import Foundation

protocol CGMG5TransmitterDelegate: AnyObject {
    
    /// received firmware from CGMG5Transmitter 
    func received(firmware: String, cGMG5Transmitter: CGMG5Transmitter)

    /// received transmitterBatteryInfo
    func received(transmitterBatteryInfo: TransmitterBatteryInfo, cGMG5Transmitter: CGMG5Transmitter)
    
    /// received transmitterStartDate
    func received(transmitterStartDate: Date, cGMG5Transmitter: CGMG5Transmitter)
    
    /// transmitter reset result
    func reset(for cGMG5Transmitter: CGMG5Transmitter, successful: Bool)
    
    /// sensor start time as received from transmitter
    func received(sensorStartDate: Date, cGMG5Transmitter: CGMG5Transmitter)
   
    /// sensor status as received from the transmitter
    func received(sensorStatus: String, cGMG5Transmitter: CGMG5Transmitter)
    
}

