//
//  ForgotPasswordViewModel.swift
//  TestingFilemanager
//
//  Created by Mikael Denys Wijaya on 20/06/23.
//


import Combine
import Foundation

protocol ForgotPasswordViewModel {
    var service: ForgotPasswordService { get }
    var email: String { get }
    init(service: ForgotPasswordService)
    func sendPasswordResetRequest()
}

final class ForgotPasswordViewModelImpl: ObservableObject, ForgotPasswordViewModel {
    
    let service: ForgotPasswordService
    @Published var email: String = ""

    private var subscriptions = Set<AnyCancellable>()
    
    init(service: ForgotPasswordService) {
        self.service = service
    }
    
    func sendPasswordResetRequest() {
        service
            .sendPasswordResetRequest(to: email)
            .sink { res in
                switch res {
                case .failure(let err):
                    print("Failed: \(err)")
                default: break
                }
            } receiveValue: {
                print("Sending request..")
            }
            .store(in: &subscriptions)
    }
}
