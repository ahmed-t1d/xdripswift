//
//  TreatmentEntryAccessor.swift
//  xdrip
//
//  Created by Eduardo Pietre on 24/12/21.
//  Copyright © 2021 Johan Degraeve. All rights reserved.
//

import Foundation
import CoreData
import os


class TreatmentEntryAccessor {
	
	// MARK: - Properties
	
	/// for logging
	private var log = OSLog(subsystem: ConstantsLog.subSystem, category: ConstantsLog.categoryApplicationDataTreatments)
	
	/// CoreDataManager to use
	private let coreDataManager:CoreDataManager
	
	// MARK: - initializer
	
	init(coreDataManager:CoreDataManager) {
		self.coreDataManager = coreDataManager
	}
	
	// MARK: - public functions
	
	/// Gives the 100 latest treatments
	///
    /// - parameters:
    ///     - howOld : maximum age, if nil then no limit in age
	/// - returns: an array with treatments, can be empty array.
	///     Order by timestamp, descending meaning the treatment at index 0 is the youngest
	func getLatestTreatments(howOld: TimeInterval?) -> [TreatmentEntry] {
		return getLatestTreatments(limit: nil, howOld: howOld)
	}
	
	/// Returns the treatments among the latest
	/// that have not yet been uploaded
	///
    /// - parameters:
    ///     - howOld : maximum age, if nil then no limit in age
	/// - returns: an array with treatments not uploaded, can be empty array.
	///     Order by timestamp, descending meaning the treatment at index 0 is the youngest
	func getRequireUploadTreatments(howOld: TimeInterval?) -> [TreatmentEntry] {
		// filter by not uploaded
        return getLatestTreatments(howOld: howOld).filter { treatment in
			return !treatment.uploaded
		}
	}
	
	/// Gives latest treatments
	///
	/// - parameters:
	///     - limit : maximum amount of treatments to return, if nil then no limit in amount
	/// - returns: an array with treatments, can be empty array.
	///     Order by timestamp, descending meaning the treatment at index 0 is the youngest
	func getLatestTreatments(limit:Int) -> [TreatmentEntry] {
		return getLatestTreatments(limit:limit, howOld:nil)
	}
	
	/// Gives treatments with maximumDays old
	///
	/// - parameters:
	///     - limit : maximum amount of treatments to return, if nil then no limit in amount
    ///     - howOld : maximum age, if nil then no limit in age
	/// - returns: an array with treatments, can be empty array.
	///     Order by timestamp, descending meaning the treatment at index 0 is the youngest
	func getLatestTreatments(limit:Int?, howOld: TimeInterval?) -> [TreatmentEntry] {
		
		// if maximum age specified then create fromdate
		var fromDate:Date?
		if let howOld = howOld, howOld >= 0 {
			fromDate = Date(timeIntervalSinceNow: howOld)
		}
		
		return getLatestTreatments(limit: limit, fromDate: fromDate)
        
	}
	
	/// Gives treatments with timestamp higher than fromDate
	///
	/// - parameters:
	///     - limit : maximum amount of treatments to return, if nil then no limit in amount
	///     - fromDate : treatment must have date > fromDate
	/// - returns: an array with treatments, can be empty array.
	///     Order by timestamp, descending meaning the treatment at index 0 is the youngest
   func getLatestTreatments(limit:Int?, fromDate:Date?) -> [TreatmentEntry] {
		return fetchTreatments(limit: limit, fromDate: fromDate)
	}
	
	/// gets most recent treatment
	func latest() -> TreatmentEntry? {
		let treatments = getLatestTreatments(limit: 1, howOld: nil)
		if treatments.count > 0 {
			return treatments.last
		} else {
			return nil
		}
	}
	
	/// deletes treatmentEntry, synchronously, in the managedObjectContext's thread
    /// - parameters:
	///     - treatmentEntry : treatmentEntry to delete
	///     - managedObjectContext : the ManagedObjectContext to use
	func delete(treatmentEntry: TreatmentEntry, on managedObjectContext: NSManagedObjectContext) {
		
		managedObjectContext.performAndWait {
			
			managedObjectContext.delete(treatmentEntry)
			
			// save changes to coredata
			do {
				try managedObjectContext.save()
			} catch {
				trace("in delete treatmentEntry,  Unable to Save Changes, error.localizedDescription  = %{public}@", log: self.log, category: ConstantsLog.categoryApplicationDataTreatments, type: .error, error.localizedDescription)
			}
            
		}
        
	}
	
	/// Given an id, returns if exists a treatment with that id.
    /// - parameters:
	///     - id : the id string
	func existsTreatmentWithId(_ id: String) -> Bool {
		return getTreatmentById(id) != nil
	}
	
	/// Given an Id, returns the TreatmentEntry with that id, if it exists.
    /// - parameters:
	///     - id : the id string
	func getTreatmentById(_ id: String) -> TreatmentEntry? {
        
		// EmptyId is not a valid id
		guard id != TreatmentEntry.EmptyId else {
			return nil
		}
		
		let fetchRequest: NSFetchRequest<TreatmentEntry> = TreatmentEntry.fetchRequest()
		
        // limit to 1, although there shouldn't be more than 1 with the same id.
		fetchRequest.fetchLimit = 1
		
        // Filter by id
		fetchRequest.predicate = NSPredicate(format: "id == %@", id)
		
		var treatment: TreatmentEntry? = nil
		
        coreDataManager.mainManagedObjectContext.performAndWait {
			do {
				// Execute Fetch Request
				// Since it returns an array, get the first elem
				treatment = (try fetchRequest.execute()).first
			} catch {
				let fetchError = error as NSError
				trace("in fetchTreatments, Unable to Execute getTreatmentById Fetch Request : %{public}@", log: self.log, category: ConstantsLog.categoryApplicationDataTreatments, type: .error, fetchError.localizedDescription)
			}
		}

		return treatment
	}
	
    /// creates array of TreatmentEntry based on array of TreatmentNSResponse
	public func newTreatmentsIfRequired(responses: [TreatmentNSResponse]) -> [TreatmentEntry] {
        
		var newTreatments: [TreatmentEntry] = []
		
		for response in responses {
			if !self.existsTreatmentWithId(response.id), let treatment = response.asNewTreatmentEntry(nsManagedObjectContext: coreDataManager.mainManagedObjectContext) {
				newTreatments.append(treatment)
			}
		}
		
		return newTreatments
        
	}
	
	// MARK: - private helper functions
	
	/// returnvalue can be empty array
	/// - parameters:
	///     - limit: maximum amount of treatments to fetch, if 0 then no limit
	///     - fromDate : if specified, only return readings with timestamp > fromDate
	/// - returns:
	///     List of treatments, descending, ie first is youngest
	private func fetchTreatments(limit:Int?, fromDate:Date?) -> [TreatmentEntry] {
		let fetchRequest: NSFetchRequest<TreatmentEntry> = TreatmentEntry.fetchRequest()
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(TreatmentEntry.date), ascending: false)]
		
		// if fromDate specified then create predicate
		if let fromDate = fromDate {
			let predicate = NSPredicate(format: "date > %@", fromDate as NSDate)
			fetchRequest.predicate = predicate
		}
		
		// set fetchLimit
		if let limit = limit, limit >= 0 {
			fetchRequest.fetchLimit = limit
		}
		
		var treatments: [TreatmentEntry] = []
		
		coreDataManager.mainManagedObjectContext.performAndWait {
			do {
				// Execute Fetch Request
				treatments = try fetchRequest.execute()
			} catch {
				let fetchError = error as NSError
				trace("in fetchTreatments, Unable to Execute fetchTreatments Fetch Request : %{public}@", log: self.log, category: ConstantsLog.categoryApplicationDataTreatments, type: .error, fetchError.localizedDescription)
			}
		}
		
		return treatments
	}
	
}

