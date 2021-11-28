import Foundation
import CoreData

/// defines the types of bluetooth peripherals
/// - bubble, dexcom G5, dexcom G4, ... which are all of category CGM
/// - M5Stack, M5StickC which are both of category M5Stack
/// - possibily more in the future, like watlaa
enum BluetoothPeripheralType: String, CaseIterable {
    
    /// M5Stack
    case M5StackType = "M5Stack"
    
    /// M5StickC
    case M5StickCType = "M5StickC"

    /// Libre 2
    case Libre2Type = "Libre 2 Direct"
    
    /// MiaoMiao
    case MiaoMiaoType = "MiaoMiao"
    
    /// bubble
    case BubbleType = "Bubble / Bubble Mini"
    
    /// DexcomG6
    case DexcomG6Type = "Dexcom G6"
    
    /// Dexcom G6 firefly
    case DexcomG6FireflyType = "Dexcom G6 Firefly"
    
    /// DexcomG5
    case DexcomG5Type = "Dexcom G5"
    
    /// DexcomG4
    case DexcomG4Type = "Dexcom G4 (Bridge)"
    
    /// Blucon
    case BluconType = "Blucon"
    
    /// BlueReader
    case BlueReaderType = "BlueReader"
    
    /// Droplet
    case DropletType = "Droplet"
    
    /// GNSentry
    case GNSentryType = "GNSentry"
      
    /// watlaa master
    case WatlaaType = "Watlaa"
    
    /// Atom
    case AtomType = "Atom"

    /// - returns: the BluetoothPeripheralViewModel. If nil then there's no specific settings for the tpe of bluetoothPeripheral
    func viewModel() -> BluetoothPeripheralViewModel? {
        
        switch self {
            
        case .M5StackType:
            return M5StackBluetoothPeripheralViewModel()
            
        case .M5StickCType:
            return M5StickCBluetoothPeripheralViewModel()
            
        case .WatlaaType:
            return WatlaaBluetoothPeripheralViewModel()
            
        case .DexcomG5Type:
            return DexcomG5BluetoothPeripheralViewModel()
            
        case .BubbleType:
            return BubbleBluetoothPeripheralViewModel()
            
        case .MiaoMiaoType:
            return MiaoMiaoBluetoothPeripheralViewModel()
            
        case .BluconType:
            return BluconBluetoothPeripheralViewModel()
            
        case .GNSentryType:
            return GNSEntryBluetoothPeripheralViewModel()
         
        case .BlueReaderType:
            return nil
            
        case .DropletType:
            return DropletBluetoothPeripheralViewModel()
            
        case .DexcomG4Type:
            return DexcomG4BluetoothPeripheralViewModel()
            
        case .DexcomG6Type:
            return DexcomG6BluetoothPeripheralViewModel()
            
        case .DexcomG6FireflyType:
            return DexcomG6FireflyBluetoothPeripheralViewModel()
            
        case .Libre2Type:
            return Libre2BluetoothPeripheralViewModel()
            
        case .AtomType:
            return AtomBluetoothPeripheralViewModel()
            
        }
        
    }
    
    func createNewBluetoothPeripheral(withAddress address: String, withName name: String, nsManagedObjectContext: NSManagedObjectContext) -> BluetoothPeripheral {
    
        switch self {
            
        case .M5StackType:
            
           let newM5Stack = M5Stack(address: address, name: name, textColor: UserDefaults.standard.m5StackTextColor ?? ConstantsM5Stack.defaultTextColor, backGroundColor: ConstantsM5Stack.defaultBackGroundColor, rotation: ConstantsM5Stack.defaultRotation, brightness: 100, alias: nil, nsManagedObjectContext: nsManagedObjectContext)
            
            // assign password stored in UserDefaults (might be nil)
            newM5Stack.blepassword = UserDefaults.standard.m5StackBlePassword
    
            return newM5Stack

        case .M5StickCType:
            
            return M5StickC(address: address, name: name, textColor: UserDefaults.standard.m5StackTextColor ?? ConstantsM5Stack.defaultTextColor, backGroundColor: ConstantsM5Stack.defaultBackGroundColor, rotation: ConstantsM5Stack.defaultRotation, alias: nil, nsManagedObjectContext: nsManagedObjectContext)
            
        case .WatlaaType:
            
            return Watlaa(address: address, name: name, alias: nil, nsManagedObjectContext: nsManagedObjectContext)
            
        case .DexcomG5Type:
            
            return DexcomG5(address: address, name: name, alias: nil, nsManagedObjectContext: nsManagedObjectContext)
            
        case .DexcomG6Type:
            
            // DexcomG6 is a DexcomG5 with isDexcomG6 set to true
            
            // the cgm transmitter itself will use the transmitter id to determine that firefly logic needs to be used
            // which means, a user could add a Dexcom G6 Firefly as a Dexcom G6 or even a Dexcom G5, the class CGMG5Transmitter will find out it's a firefly, based on transmitter id and handle it as a firefly
            // It plays only a role in the RootViewController that a G6 Firefly is selected, because then also the user needs to add a code

            let dexcomG6 = DexcomG5(address: address, name: name, alias: nil, nsManagedObjectContext: nsManagedObjectContext)
            dexcomG6.isDexcomG6 = true

            return dexcomG6
            
        case .DexcomG6FireflyType:
            
            // DexcomG6 Firefly is a DexcomG5 with isFirefly set to true
            
            // the cgm transmitter itself will use the transmitter id to determine that firefly logic needs to be used
            // which means, a user could add a Dexcom G6 Firefly as a Dexcom G6 or even a Dexcom G5, the class CGMG5Transmitter will find out it's a firefly, based on transmitter id and handle it as a firefly
            // It plays only a role in the RootViewController that a G6 Firefly is selected, because then also the user needs to add a code
            
            let dexcomG6Firefly = DexcomG5(address: address, name: name, alias: nil, nsManagedObjectContext: nsManagedObjectContext)
            dexcomG6Firefly.isFirefly = true
            
            return dexcomG6Firefly
            
        case .BubbleType:
            
            return Bubble(address: address, name: name, alias: nil, nsManagedObjectContext: nsManagedObjectContext)
            
        case .MiaoMiaoType:
            
            return MiaoMiao(address: address, name: name, alias: nil, nsManagedObjectContext: nsManagedObjectContext)
            
        case .BluconType:
            
            return Blucon(address: address, name: name, alias: nil, nsManagedObjectContext: nsManagedObjectContext)
            
        case .GNSentryType:
            
            return GNSEntry(address: address, name: name, alias: nil, nsManagedObjectContext: nsManagedObjectContext)
  
        case .BlueReaderType:
            
            return BlueReader(address: address, name: name, alias: nil, nsManagedObjectContext: nsManagedObjectContext)
            
        case .DropletType:
            
            return Droplet(address: address, name: name, alias: nil, nsManagedObjectContext: nsManagedObjectContext)
            
        case .DexcomG4Type:
            
            return DexcomG4(address: address, name: name, alias: nil, nsManagedObjectContext: nsManagedObjectContext)
            
        case .Libre2Type:
            
            return Libre2(address: address, name: name, alias: nil, nsManagedObjectContext: nsManagedObjectContext)
            
        case .AtomType:
            
            return Atom(address: address, name: name, alias: nil, nsManagedObjectContext: nsManagedObjectContext)
            
        }
        
    }

    /// to which category of bluetoothperipherals does this type belong (M5Stack, CGM, ...)
    func category() -> BluetoothPeripheralCategory {
        
        switch self {
            
        case .M5StackType, .M5StickCType:
            return .M5Stack
            
        case .DexcomG5Type, .BubbleType, .MiaoMiaoType, .BluconType, .GNSentryType, .BlueReaderType, .DropletType, .DexcomG4Type, .DexcomG6Type, .WatlaaType, .Libre2Type, .AtomType, .DexcomG6FireflyType:
            return .CGM
            
        }
        
    }
    
    /// does the device need a transmitterID (currently only Dexcom and Blucon)
    func needsTransmitterId() -> Bool {
        
        switch self {
            
        case .M5StackType, .M5StickCType, .WatlaaType, .BubbleType, .MiaoMiaoType, .GNSentryType, .BlueReaderType, .DropletType, .Libre2Type, .AtomType:
            return false
            
        case .DexcomG5Type, .BluconType, .DexcomG4Type, .DexcomG6Type, .DexcomG6FireflyType:
            return true

        }
        
    }
    
    /// - returns nil if id to validate has expected length and type of characters etc.
    /// - returns error text if transmitterId is not ok
    func validateTransmitterId(transmitterId:String) -> String? {
        
        switch self {
            
        case .DexcomG5Type, .DexcomG6Type, .DexcomG6FireflyType:
            
            // length for G5 and G6 is 6
            if transmitterId.count != 6 {
                return Texts_ErrorMessages.TransmitterIDShouldHaveLength6
            }
            
            //verify allowed chars
            let regex = try! NSRegularExpression(pattern: "[a-zA-Z0-9]", options: .caseInsensitive)
            if !transmitterId.validate(withRegex: regex) {
                return Texts_ErrorMessages.DexcomTransmitterIDInvalidCharacters
            }
            
            // validation successful
            return nil
            
        case .DexcomG4Type:

            let regex = try! NSRegularExpression(pattern: "[a-zA-Z0-9]", options: .caseInsensitive)
            if !transmitterId.validate(withRegex: regex) {
                return Texts_ErrorMessages.DexcomTransmitterIDInvalidCharacters
            }
            if transmitterId.count != 5 {
                return Texts_ErrorMessages.TransmitterIDShouldHaveLength5
            }
            return nil
            
        case .M5StackType, .M5StickCType, .WatlaaType, .BubbleType, .MiaoMiaoType, .GNSentryType, .BlueReaderType, .DropletType, .Libre2Type, .AtomType:
            // no transmitter id means no validation to do
            return nil
            
        case .BluconType:
            
            let regex = try! NSRegularExpression(pattern: "^[0-9]{1,5}$", options: .caseInsensitive)
            if !transmitterId.validate(withRegex: regex) {
                return Texts_ErrorMessages.TransmitterIdBluCon
            }
            
            if transmitterId.count != 5 {
                return Texts_ErrorMessages.TransmitterIdBluCon
            }
            return nil
            
        }
        
    }
    
    /// is it web oop supported or not.
    func canWebOOP() -> Bool {
        
        switch self {
            
        case .M5StackType, .M5StickCType, .WatlaaType, .DexcomG4Type, .DexcomG5Type, .DexcomG6Type, .BluconType, .BlueReaderType, .DropletType , .GNSentryType, .DexcomG6FireflyType:
            return false
            
        case .BubbleType, .MiaoMiaoType, .AtomType:
            return true
            
        case .Libre2Type:
            // oop web can still be used for Libre2 because in the end the data received is Libre 1 format, we can use oop web to get slope parameters
            return true
                        
        }
        
    }
    
    /// can use non fixed slopes or not
    func canUseNonFixedSlope() -> Bool {
       
       switch self {
           
       case .M5StackType, .M5StickCType, .DexcomG4Type, .DexcomG5Type, .DexcomG6Type, .DexcomG6FireflyType:
           return false
           
       case .BubbleType, .MiaoMiaoType, .WatlaaType, .BluconType, .BlueReaderType, .DropletType , .GNSentryType, .AtomType:
           return true
        
       case .Libre2Type:
            return true

       }
       
    }
    
}
