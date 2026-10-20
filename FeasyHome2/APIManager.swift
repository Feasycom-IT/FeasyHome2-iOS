//
//  APIManager.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2025/1/7.
//

import Foundation
import Alamofire

// 定义 Base URL 和 Endpoint
let baseURL = "https://api.feasycom.com/feasyhome"
let getCaptchaEndpoint = "/api/user/getCaptcha"// 获取验证码
let mobileLoginEndpoint = "/api/user/mobilelogin"// 验证码登录

// 获取验证码
struct CaptchaResponse: Decodable {
    let code: Int           // 状态码
    let msg: String         // 响应消息
    let time: Int           // 时间戳
    let data: Int           // 验证码
}

// 验证码登录
struct LoginResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: DataClass
}

struct DataClass: Codable {
    let userinfo: UserInfo
}

struct UserInfo: Codable {
    let id: Int
    let username: String
    let nickname: String
    let mobile: String
    let avatar: String
    let score: Int
    let token: String
    let user_id: Int
    let createtime: Int
    let expiretime: Int
    let expires_in: Int
}

// MARK: - FamilyListResponse
struct FamilyListResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: [Family]
}

// MARK: - Family
struct Family: Codable {
    let id: Int
    let familyName: String
    let familyStr: String
    let userID: Int
    let memberID: String
    let manageID: String
    let networkID: String
    let networkData: String
    let updateTime: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case familyName = "family_name"
        case familyStr = "family_str"
        case userID = "user_id"
        case memberID = "member_id"
        case manageID = "manage_id"
        case networkID = "network_id"
        case networkData = "network_data"
        case updateTime = "updatetime"
    }
}

// MARK: - CreateFamilyResponse
struct CreateFamilyResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: String? // 因为 data 为 null，可以定义为可选类型
}

// MARK: - DeleteFamilyResponse
struct DeleteFamilyResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: String? // 因为 data 为 null，可以定义为可选类型
}

// MARK: - 数据模型
struct Room: Codable {
    var id: Int
    var roomName: String
    var familyId: Int
    var userId: Int
    var network: Int
    var roomCode: Int
    var deviceCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case roomName = "room_name"
        case familyId = "family_id"
        case userId = "user_id"
        case network
        case roomCode = "room_code"
        case deviceCount
    }
}

struct RoomListResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: [Room]
}

struct DefaultResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: String?
}

// MARK: - 灯具类型数据模型
struct LightListResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: [LightType]
}

struct LightType: Codable {
    let id: Int
    let text: String
    let code: String
}

// MARK: - 灯具位置数据模型
struct LocationListResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: [LightLocation]
}

struct LightLocation: Codable {
    let id: Int
    let text: String
    let code: String
}

// MARK: - 可用群组地址数据模型
struct EnableGroupAddressResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: Int
}

// MARK: - 数据模型
struct GroupListResponse: Decodable {
    let code: Int
    let msg: String
    let time: Int
    let data: [LightDeviceGroup]
}

struct LightDeviceGroup: Decodable {
    let id: Int
    let groupName: String
    let roomId: Int
    let userId: Int
    let familyId: Int
    let deviceType: String
    let address: String
    let addressNumber: Int
    let location: String
    let light: String
    let deviceCount: Int
    let network: Int
    let createTime: Int
    let updateTime: Int
    
    // 将原始 JSON 中的字段名与 Swift 属性名做映射
    enum CodingKeys: String, CodingKey {
        case id
        case groupName = "group_name"
        case roomId = "room_id"
        case userId = "user_id"
        case familyId = "family_id"
        case deviceType = "device_type"
        case address
        case addressNumber = "address_number"
        case location
        case light
        case deviceCount = "device_count"
        case network
        case createTime = "createtime"
        case updateTime = "updatetime"
    }
}

// MARK: - 数据模型

struct Family_Home: Codable {
    let id: Int
    let familyName: String
    let familyStr: String
    let userID: Int
    let memberID: String
    let manageID: String
    let networkID: String
    let networkData: String
    let updateTime: Int
    let authType: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case familyName = "family_name"
        case familyStr = "family_str"
        case userID = "user_id"
        case memberID = "member_id"
        case manageID = "manage_id"
        case networkID = "network_id"
        case networkData = "network_data"
        case updateTime = "updatetime"
        case authType = "auth_type"
    }
}

struct Room_Home: Codable {
    var id: Int
    var roomName: String
    var familyId: Int
    var userId: Int
    var network: Int
    var roomCode: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case roomName = "room_name"
        case familyId = "family_id"
        case userId = "user_id"
        case network
        case roomCode = "room_code"
    }
}

struct HomeRoomDeviceResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: HomeRoomDeviceData
}

struct HomeRoomDeviceData: Codable {
    let familyList: [Family_Home]
    let roomList: [Room_Home]
    let lightGroupList: [LightGroup]
    let curtainGroupList: [CurtainGroup]
    let panelList: [Panel]
    let voiceList: [Voice]
}

struct LightGroup: Codable {
    var id: Int
    var groupName: String
    var roomId: Int
    var userId: Int
    var familyId: Int
    var deviceType: String
    var address: String
    var addressNumber: Int
    var location: String
    var light: String
    var deviceCount: Int
    var network: Int
    var createTime: Int
    var updateTime: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case groupName = "group_name"
        case roomId = "room_id"
        case userId = "user_id"
        case familyId = "family_id"
        case deviceType = "device_type"
        case address
        case addressNumber = "address_number"
        case location
        case light
        case deviceCount = "device_count"
        case network
        case createTime = "createtime"
        case updateTime = "updatetime"
    }
}

struct CurtainGroup: Codable {
    var id: Int
    var groupName: String
    var roomId: Int
    var userId: Int
    var familyId: Int
    var deviceType: String
    var address: String
    var addressNumber: Int
    var groupCode: String
    var deviceCount: Int
    var updateTime: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case groupName = "group_name"
        case roomId = "room_id"
        case userId = "user_id"
        case familyId = "family_id"
        case deviceType = "device_type"
        case address
        case addressNumber = "address_number"
        case groupCode = "group_code"
        case deviceCount = "device_count"
        case updateTime = "updateTime"
    }
}

// MARK: - 面板信息
struct Panel: Codable {
    var id: Int
    var roomId: Int
    var familyId: Int
    var deviceType: String
    var secondType: String
    var mac: String
    var deviceVer: String?
    var userId: Int
    var deleteTime: Int?
    var createTime: Int
    var deviceName: String
    var percent: Int
    var enable: Int
    var destination: Int
    var deviceId: String?
    var layoutId: String?
    var updateTime: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case roomId = "room_id"
        case familyId = "family_id"
        case deviceType = "device_type"
        case secondType = "second_type"
        case mac
        case deviceVer = "device_ver"
        case userId = "user_id"
        case deleteTime = "deleteTime"
        case createTime = "createtime"
        case deviceName = "device_name"
        case percent
        case enable
        case destination
        case deviceId = "device_id"
        case layoutId = "layout_id"
        case updateTime = "updatetime"
    }
}

struct Voice: Codable {
    var id: Int
    var roomId: Int
    var familyId: Int
    var deviceType: String
    var deviceVer: String
    var userId: Int
    var createTime: Int
    var secondType: String?
    var mac: String
    var updateTime: Int
    var deviceName: String
    var destination: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case roomId = "room_id"
        case familyId = "family_id"
        case deviceType = "device_type"
        case deviceVer = "device_ver"
        case userId = "user_id"
        case createTime = "createtime"
        case secondType = "second_type"
        case mac
        case updateTime = "updatetime"
        case deviceName = "device_name"
        case destination
    }
}

// MARK: - DeviceListResponse
struct DeviceListResponse: Codable {
    var code: Int
    var msg: String
    var data: DeviceListData?
    
    enum CodingKeys: String, CodingKey {
        case code
        case msg
        case data
    }
}

// MARK: - DeviceListData
struct DeviceListData: Codable {
    var roomName: String?
    var list: [Device]
    
    enum CodingKeys: String, CodingKey {
        case roomName = "room_name"
        case list
    }
}

// MARK: - Device
struct Device: Codable {
    var id: Int
    var groupId: Int?
    var roomId: Int
    var familyId: Int
    var deviceType: String
    var secondType: String?
    var mac: String
    var deviceVer: String
    var userId: Int
    var groupName: String?
    var deleteTime: Int?
    var createTime: Int
    var address: String
    var network: Int
    var deviceId: String?
    var destination: Int
    var isLeader: Int
    var isOn: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case groupId = "group_id"
        case roomId = "room_id"
        case familyId = "family_id"
        case deviceType = "device_type"
        case secondType = "second_type"
        case mac
        case deviceVer = "device_ver"
        case userId = "user_id"
        case groupName = "group_name"
        case deleteTime = "deleteTime"
        case createTime = "createtime"
        case address
        case network
        case deviceId = "device_id"
        case destination
        case isLeader = "is_leader"
        case isOn = "isOn"
    }
}

// MARK: - 语音灯具组表 响应模型
struct VoiceLightTableResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: VoiceLightTableData
}

struct VoiceLightTableData: Codable {
    let id: Int
    let tableData: String?
    let mac: String
    let roomId: Int
    let firstIndex: Int
    let updateTime: Int
    let familyId: Int
    let roomCode: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case tableData = "tableData"
        case mac
        case roomId = "room_id"
        case firstIndex = "first_index"
        case updateTime = "updatetime"
        case familyId = "family_id"
        case roomCode = "room_code"
    }
}

// MARK: - 窗帘组表响应模型
struct VoiceCurtainTableResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: VoiceCurtainTableData
}

struct VoiceCurtainTableData: Codable {
    let id: Int
    let mac: String
    let tableData: String?       // 可能为 null
    let firstIndex: String       // 是 String 类型（例如 "64"）
    let roomId: Int
    let updateTime: Int
    let familyId: Int
    let roomCode: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case mac
        case tableData
        case firstIndex = "first_index"
        case roomId = "room_id"
        case updateTime = "updatetime"
        case familyId = "family_id"
        case roomCode = "room_code"
    }
}

struct SceneDetailResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: SceneAndGroupAndCurtainGroupList
}

struct SceneAndGroupAndCurtainGroupList: Codable {
    let scene: SceneDetailItem
    let groupList: [SceneDetailLightGroup]
    let curtainGroupList: [SceneDetailCurtainGroup]
}

struct SceneGroupListResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: GroupAndCurtainGroupAndRoomList
}

struct GroupAndCurtainGroupAndRoomList: Codable {
    let groupList: [LightGroup]
    let curtainGroupList: [CurtainGroup]
    let roomList:[Room_Home]
}

struct HomeSceneListResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: HomeAndSceneList
}

struct HomeAndSceneList:Codable {
    let familyList:[Family_Home]
    let sceneList:[SceneListItem]
    let nowScene:SceneCurrentItem?
}

struct SceneCurrentItem: Codable {
    var id: Int
    var sceneName: String
    var familyid: Int
    var sceneImageUrl: String
    var sceneCode: String
    var is_on: Int
    var bind_group: Int?
    var updateTime: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case sceneName = "scene_name"
        case familyid = "family_id"
        case sceneImageUrl = "scene_image"
        case sceneCode = "scene_code"
        case is_on
        case bind_group
        case updateTime
    }
}

struct SceneListItem: Codable {
    var id: Int
    var sceneName: String
    var familyid: Int
    var sceneImageUrl: String
    var sceneCode: String
    var is_on: Int
    var bind_group:Int
    var updateTime:Int?
    var groupList: [SceneLightGroup]
    var curtainGroupList:[SceneDetailCurtainGroup]
    
    enum CodingKeys: String, CodingKey {
        case id
        case sceneName = "scene_name"
        case familyid = "family_id"
        case sceneImageUrl = "scene_image"
        case sceneCode = "scene_code"
        case is_on
        case bind_group
        case updateTime
        case groupList
        case curtainGroupList
    }
}

struct SceneConfigListResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: [SceneItem]
}

struct SceneItem: Codable {
    var id: Int
    var sceneName: String
    var sceneImageUrl: String
    var sceneCode: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case sceneName = "scene_name"
        case sceneImageUrl = "scene_image"
        case sceneCode = "scene_code"
    }
}

struct SceneDetailItem: Codable {
    var id: Int
    var sceneName: String
    var familyid: Int
    var sceneImageUrl: String
    var sceneCode: String
    var is_on: Int
    var bind_group: Int
    var updateTime: Int?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case sceneName = "scene_name"
        case familyid = "family_id"
        case sceneImageUrl = "scene_image"
        case sceneCode = "scene_code"
        case is_on
        case bind_group
        case updateTime
    }
}

struct JoinSceneGroupRequest :Codable {
    var scene_code:String
    var family_id:Int
    var room_id:Int
    var address:String
    var device_type:String
    var group_id:Int
    var type:String
    var room_name:String
    var group_name:String
    
    init() {
        self.scene_code = ""
        self.family_id = 0
        self.room_id = 0
        self.address = ""
        self.device_type = ""
        self.group_id = 0
        self.type = ""
        self.room_name = ""
        self.group_name = ""
    }
}

struct SceneLightGroup: Codable {
    var id: Int
    var groupID:Int
    var groupAddress:String
    var deviceType: String
    var uid: Int
    var groupName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case groupID = "group_id"
        case groupAddress = "group_address"
        case deviceType = "device_type"
        case uid
        case groupName = "group_name"
    }
}

struct SceneDetailLightGroup: Codable {
    var id: Int
    var roomID:Int
    var groupID:Int
    var groupAddress:String
    var deviceType: String
    var uid: Int
    var groupName: String
    var deviceCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case roomID = "room_id"
        case groupID = "group_id"
        case groupAddress = "group_address"
        case deviceType = "device_type"
        case uid
        case groupName = "group_name"
        case deviceCount = "device_count"
    }
    init(id:Int, roomID:Int, groupID:Int, groupAddress:String, deviceType:String, uid:Int, groupNmae:String, deviceCount: Int) {
        self.id = id
        self.roomID = roomID
        self.groupID = groupID
        self.groupAddress = groupAddress
        self.deviceType = deviceType
        self.uid = uid
        self.groupName = groupNmae
        self.deviceCount = deviceCount
    }
}

struct SceneDetailCurtainGroup: Codable {
    var id: Int
    var roomID: Int?
    var groupID: Int
    var groupAddress: String
    var deviceType: String
    var uid: Int
    var groupName: String
    var deviceCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case roomID = "room_id"
        case groupID = "group_id"
        case groupAddress = "group_address"
        case deviceType = "device_type"
        case uid
        case groupName = "group_name"
        case deviceCount = "device_count"
    }
    init(id:Int, roomID:Int, groupID:Int, groupAddress:String, deviceType:String, uid:Int, groupNmae:String, deviceCount: Int) {
        self.id = id
        self.roomID = roomID
        self.groupID = groupID
        self.groupAddress = groupAddress
        self.deviceType = deviceType
        self.uid = uid
        self.groupName = groupNmae
        self.deviceCount = deviceCount
    }
}

struct MemberListResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: [Member]
}

struct Member: Codable {
    var id: Int
    var nickname: String
    var mobile: String
    var avatar: String
    var username: String
    var auth_type: String
    var url: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case nickname
        case mobile
        case avatar
        case username
        case auth_type
        case url
    }
}

struct UserInfoResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: UserInfo
}

struct UploadImageResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: UploadedInfo?
}

struct UploadedInfo: Codable {
    let url: String
}

struct CurtainType: Codable {
    let id: Int
    let text: String
    let code: String
}

struct CurtainTypeListResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: [CurtainType]?
}

struct CurtainGroupListResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: [CurtainGroup]?
}

// MARK: - 布局项
struct LayoutItem: Codable {
    var title: String
    var select: String
    var bindId: String
    var bindType: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case select
        case bindId = "bind_id"
        case bindType = "bind_type"
    }
}

// MARK: - 接口响应数据包装
struct PanelDetailData: Codable {
    var panel: Panel
    var layoutList: [LayoutItem]
}

// MARK: - 总体响应结构
struct PanelDetailResponse: Codable {
    var code: Int
    var msg: String
    var time: Int
    var data: PanelDetailData
}

struct UpdateLayoutRequest: Encodable {
    var mac: String
    var familyId: Int
    var roomId: Int
    var secondType: String
    var btnId: Int
    var bindId: String
    var bindType: String
    var doType: Int
    var deviceType: String
    
    enum CodingKeys: String, CodingKey {
        case mac
        case familyId = "family_id"
        case roomId = "room_id"
        case secondType = "second_type"
        case btnId = "btn_id"
        case bindId = "bind_id"
        case bindType = "bind_type"
        case doType = "do_type"
        case deviceType = "device_type"
    }
}

struct BaseResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: String? // 可为 null
}























class APIManager {
    // 单例模式（如果需要统一管理多个网络请求）
    static let shared = APIManager()
    public init() {}
    
    // 获取手机验证码的方法
    func fetchCaptcha(mobile: String, completion: @escaping (Result<CaptchaResponse, Error>) -> Void) {
        // 请求参数
        let parameters: [String: String] = ["mobile": mobile]
        
        // 拼接完整 URL
        let url = baseURL + getCaptchaEndpoint
        
        // 使用 Alamofire 发起请求
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default)
            .validate() // 验证 HTTP 状态码
            .responseDecodable(of: CaptchaResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let captchaResponse):
                    // 请求成功，返回数据
                    completion(.success(captchaResponse))
                case .failure(let error):
                    // 请求失败，返回错误
                    completion(.failure(error))
                }
            }
    }
    
    func loginWithCaptcha(mobile: String, captcha: String, completion: @escaping (Result<String, AFError>) -> Void) {
        let url = "https://api.feasycom.com/feasyhome/api/user/mobilelogin"
        let parameters: [String: Any] = [
            "mobile": mobile,
            "captcha": captcha
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: ["Content-Type": "application/x-www-form-urlencoded; charset=utf-8"])
            .validate()
            .responseDecodable(of: LoginResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let loginResponse):
                    if loginResponse.code == 1 {
                        let token = loginResponse.data.userinfo.token
                        completion(.success(token))
                    } else {
                        // 根据业务需求处理错误代码
                        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: loginResponse.code))
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - 获取家庭列表
    func fetchFamilyList(completion: @escaping (Result<[Family], AFError>) -> Void) {
        let url = "https://api.feasycom.com/feasyhome/api/family/familyList"
        
        // 获取 Token
        guard let token = TokenManager.shared.getToken() else {
            let error = AFError.explicitlyCancelled
            completion(.failure(error))
            return
        }
        
        // 请求头，将 token 放入 Headers 中
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
            "token": token // 添加 token 到 Headers
        ]
        
        // 如果 API 不需要 Body 参数，可以传空字典或使用不同的 Encoding
        AF.request(url, method: .post, parameters: nil, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: FamilyListResponse.self) { response in
                if let request = response.request {
                    debugPrint(request)
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let familyListResponse):
                    if familyListResponse.code == 1 {
                        completion(.success(familyListResponse.data))
                    } else {
                        // 处理业务逻辑错误
                        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: familyListResponse.code))
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - 创建家庭
    func createFamily(familyName: String, networkData: String, networkId: String, familyStr: String, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = "https://api.feasycom.com/feasyhome/api/family/createFamily"
        
        // 获取 Token
        guard let token = TokenManager.shared.getToken() else {
            let error = AFError.explicitlyCancelled
            completion(.failure(error))
            return
        }
        
        // 参数
        let parameters: [String: Any] = [
            "familyName": familyName,
            "networkData": networkData,
            "networkId": networkId,
            "familyStr": familyStr
        ]
        
        // 请求头，将 token 放入 Headers 中
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
            "token": token
        ]
        
        // 发送 POST 请求，带有 Body 参数
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: CreateFamilyResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let createFamilyResponse):
                    if createFamilyResponse.code == 1 {
                        completion(.success(()))
                    } else {
                        // 处理业务逻辑错误
                        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: createFamilyResponse.code))
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - 删除家庭
    func deleteFamily(familyId: Int, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/family/deleteFamily"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = ["family_id": familyId]
        
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DeleteFamilyResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(()))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - 修改家庭名称
    func modifyFamilyName(familyId: Int, familyName: String, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/family/modifyFamilyName"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = ["family_id": familyId, "family_name": familyName]
        
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DeleteFamilyResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(()))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: 获取房间列表
    func fetchRoomList(familyId: Int, completion: @escaping (Result<[Room], AFError>) -> Void) {
        let url = baseURL + "/api/family/roomList"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = ["family_id": familyId]
        
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: RoomListResponse.self) { response in
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                switch response.result {
                case .success(let roomListResponse):
                    if roomListResponse.code == 1 {
                        completion(.success(roomListResponse.data))
                    } else {
                        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: roomListResponse.code))
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: 创建房间
    func createRoom(roomName: String, familyId: String, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/family/createRoom"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = ["roomName": roomName, "family_id": familyId]
        
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(()))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: 删除房间
    func deleteRoom(roomId: Int, familyId: Int, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/family/deleteRoom"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = ["room_id": roomId, "family_id": familyId]
        
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(()))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: 修改房间名称
    func modifyRoomName(roomId: Int, roomName: String, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/family/modifyRoomName"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = ["room_id": roomId, "room_name": roomName]
        
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(()))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - 首页家庭、房间、组列表
    func fetchHomeRoomAndDeviceData(familyId: String, roomId: String, completion: @escaping (Result<HomeRoomDeviceResponse, AFError>) -> Void) {
        let url = baseURL + "/api/family/index"
        
        // 请求参数
        let parameters: [String: Any] = [
            "family_id": familyId,
            "room_id": roomId
        ]
        
        // 获取 Token
        guard let token = TokenManager.shared.getToken() else {
            let error = AFError.explicitlyCancelled
            completion(.failure(error))
            return
        }
        
        // 请求头
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        // 发起 POST 请求
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: HomeRoomDeviceResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result):
                    completion(.success(result))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - 获取灯具类型列表
    func fetchLightList(completion: @escaping (Result<[LightType], AFError>) -> Void) {
        let url = baseURL + "/api/family/getLightList"
        
        // 获取 Token
        guard let token = TokenManager.shared.getToken() else {
            let error = AFError.explicitlyCancelled
            completion(.failure(error))
            return
        }
        
        // 请求头
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "token": token
        ]
        
        // 发起 POST 请求
        AF.request(url, method: .post, headers: headers)
            .validate()
            .responseDecodable(of: LightListResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result):
                    completion(.success(result.data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - 获取灯具位置列表
    func fetchLocationList(completion: @escaping (Result<[LightLocation], AFError>) -> Void) {
        let url = baseURL + "/api/family/getLocationList"
        
        // 获取 Token
        guard let token = TokenManager.shared.getToken() else {
            let error = AFError.explicitlyCancelled
            completion(.failure(error))
            return
        }
        
        // 请求头
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "token": token
        ]
        
        // 发起 POST 请求
        AF.request(url, method: .post, headers: headers)
            .validate()
            .responseDecodable(of: LocationListResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result):
                    completion(.success(result.data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - 获取可用群组地址
    func fetchEnableGroupAddress(familyId: String, deviceType: String, completion: @escaping (Result<Int, AFError>) -> Void) {
        let url = baseURL + "/api/family/enableGroupAddress"
        
        // 请求参数
        let parameters: [String: Any] = [
            "family_id": familyId,
            "device_type": deviceType
        ]
        
        // 获取 Token
        guard let token = TokenManager.shared.getToken() else {
            let error = AFError.explicitlyCancelled
            completion(.failure(error))
            return
        }
        
        // 请求头
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "token": token
        ]
        
        // 发起 POST 请求
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: EnableGroupAddressResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result):
                    completion(.success(result.data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - 添加组
    func createGroup(groupName: String, location: String, light: String, deviceType: String, familyId: String, roomId: String, address: String, addressNumber: String, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/device/createGroup"
        
        // 请求参数
        let parameters: [String: Any] = [
            "groupName": groupName,
            "location": location,
            "light": light,
            "device_type": deviceType,
            "family_id": familyId,
            "room_id": roomId,
            "address": address,
            "address_number": addressNumber
        ]
        
        // 获取 Token
        guard let token = TokenManager.shared.getToken() else {
            let error = AFError.explicitlyCancelled
            completion(.failure(error))
            return
        }
        
        // 请求头
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "token": token
        ]
        
        // 发起 POST 请求
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response { response in
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - 获取灯具群组列表
    func getGroupList(roomId: String, completion: @escaping (Result<[LightDeviceGroup], AFError>) -> Void) {
        let url = baseURL + "/api/device/groupList"
        
        // 请求参数
        let parameters: [String: Any] = [
            "room_id": roomId
        ]
        
        // 获取 Token
        guard let token = TokenManager.shared.getToken() else {
            let error = AFError.explicitlyCancelled
            completion(.failure(error))
            return
        }
        
        // 请求头
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "token": token
        ]
        
        // 发起 POST 请求
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: GroupListResponse.self) { response in
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let groupListResponse):
                    if groupListResponse.code == 1 {
                        // 返回成功，传递数据
                        completion(.success(groupListResponse.data))
                    } else {
                        // 处理接口返回的失败情况
                        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 500))
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: 设备加入组
    func addDeviceToGroup(secondType: String, mac: String, deviceVer: String, familyId: String, roomId: String, groupId: String, groupName: String, address: String, deviceType: String, deviceId: String, destination: String, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/device/createDevice"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = [
            "secondType": secondType,
            "mac": mac,
            "device_ver": deviceVer,
            "family_id": familyId,
            "room_id": roomId,
            "group_id": groupId,
            "group_name": groupName,
            "address": address,
            "device_type": deviceType,
            "device_id": deviceId,
            "destination": destination
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(()))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: 删除组
    func deleteGroup(familyId: String, roomId: String, address: String, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/device/deleteGroup"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = [
            "family_id": familyId,
            "room_id": roomId,
            "address": address
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(()))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: 获取组中灯具列表
    func fetchDeviceList(roomId: String, address: String, completion: @escaping (Result<[Device], AFError>) -> Void) {
        let url = baseURL + "/api/device/list"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = [
            "room_id": roomId,
            "address": address
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DeviceListResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    // 返回成功，传递设备列表
                    completion(.success(result.data?.list ?? []))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: 灯具退网
    func deleteDevice(familyId: String, address: String, mac: String, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/device/deleteDevice"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = [
            "family_id": familyId,
            "address": address,
            "mac": mac
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    // 返回成功
                    completion(.success(()))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: - 添加语音模块
    func createVoiceModule(familyId: String, roomId: String, mac: String, deviceVer: String, deviceType: String, destination: String, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/voice/createVoice"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = [
            "family_id": familyId,
            "room_id": roomId,
            "mac": mac,
            "device_ver": deviceVer,
            "device_type": deviceType,
            "destination": destination
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(()))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - 获取语音灯具组表
    func fetchVoiceLightTable(mac: String, completion: @escaping (Result<VoiceLightTableData, AFError>) -> Void) {
        // 构造 URL
        let encodedMac = mac.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? mac
        let url = baseURL + "/api/voice/lightTableList?mac=\(encodedMac)"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "token": token
        ]
        
        AF.request(url, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: VoiceLightTableResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(result.data))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: - 获取语音窗帘组表
    func fetchVoiceCurtainTable(mac: String, completion: @escaping (Result<VoiceCurtainTableData, AFError>) -> Void) {
        let encodedMac = mac.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? mac
        let url = baseURL + "/api/voice/curtainTableList?mac=\(encodedMac)"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "token": token
        ]
        
        AF.request(url, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: VoiceCurtainTableResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(result.data))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: - 删除语音盒
    func deleteVoiceBox(familyId: String, mac: String, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/voice/deleteVoice"
        
        // 获取 Token
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        // 请求参数
        let parameters: [String: Any] = [
            "family_id": familyId,
            "mac": mac
        ]
        
        // 请求头
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        // 发起 POST 请求
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                if let request = response.request {
                    debugPrint(request)
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(()))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: - 创建面板
    func createPanel(familyId: String, roomId: String, mac: String, deviceType: String, secondType: String, destination: String, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/panel/createPanel"
        
        // 获取 Token
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        // 所有参数为 String 类型
        let parameters: [String: String] = [
            "family_id": familyId,
            "room_id": roomId,
            "mac": mac,
            "device_type": deviceType,
            "second_type": secondType,
            "destination": destination
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(()))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - 面板详情
    func fetchPanelDetail(mac: String, completion: @escaping (Result<PanelDetailData, AFError>) -> Void) {
        let url = baseURL + "/api/panel/panelDetail"
        
        // 获取 Token
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        // 所有参数为 String 类型
        let parameters: [String: String] = [
            "mac": mac
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: PanelDetailResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(result.data))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    
    // MARK: - 面板按钮绑定组
    func updatePanelLayout(_ request: UpdateLayoutRequest, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/panel/updateLayout"
        
        // 获取 Token
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "token": token
        ]
        
        AF.request(url, method: .post, parameters: request, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of: BaseResponse.self) { response in
                
                if let requestData = try? JSONEncoder().encode(request),
                   let jsonString = String(data: requestData, encoding: .utf8) {
                    print("Request JSON: \(jsonString)")
                }
                debugPrint(response)
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(()))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - 删除面板
    func deletePanel(mac: String, familyId: Int, roomId: Int, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/panel/deletePanel"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        // 所有参数转为 String 传递
        let parameters: [String: String] = [
            "mac": mac,
            "family_id": String(familyId),
            "room_id": String(roomId)
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(()))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }




    
    
    
    
    

    
    // MARK: - 退出登录
    func logout(completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/user/logout"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        AF.request(url, method: .post, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result):
                    if result.code == 1 {
                        completion(.success(()))
                    } else {
                        completion(.failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: result.code))))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    func joinFamily(shareUserID:String, authType:String, familyID:Int, completion: @escaping (Result<Void, AFError>) ->Void) {
        let url = baseURL + "/api/family/joinFamily"
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        let parameters:[String:Any] = [
            "family_id":familyID,
            "auth_type":"normal",
            "share_user_id":shareUserID]
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                if let request = response.request {
                        debugPrint(request)
                        debugPrint(response)
                }
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(()))
                    
                case .failure(let error):
                    completion(.failure(error))
                case .success(_):
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                }
            }
    }
    
}

class SceneNetManager: APIManager {
    static let shareInstance = SceneNetManager()
    private override init() {
        super.init()
    }
    
    // MARK: 场景组列表
    func fetchSceneGroupList(roomId: Int, familyId: Int, completion: @escaping (Result<GroupAndCurtainGroupAndRoomList, AFError>) -> Void) {
        let url = baseURL + "/api/scene/groupList"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = ["room_id": roomId, "family_id": familyId]
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: SceneGroupListResponse.self) { response in
                debugPrint(response.request!)
                debugPrint(response)
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(result.data))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    // MARK: 场景列表
    func fetchHomeSceneList(familyId: Int, completion: @escaping (Result<HomeAndSceneList, AFError>) -> Void) {
        let url = baseURL + "/api/scene/index"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = ["family_id": familyId]
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: HomeSceneListResponse.self) { response in
                debugPrint(response.request!)
                debugPrint(response)
                switch response.result {
                case .success(let homeSceneListResponse): //where result.code == 1:
                    if homeSceneListResponse.code == 1 {
                        completion(.success(homeSceneListResponse.data))
                    }
                    //                case .success:
                    //                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: 场景配置列表
    func fetchSceneConfigList(familyId:Int, completion: @escaping (Result<[SceneItem], AFError>) -> Void) {
        let url = baseURL + "/api/scene/sceneConfigList"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = ["family_id": familyId]
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        AF.request(url, method: .post, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: SceneConfigListResponse.self) { response in
                if let request = response.request {
                    debugPrint(request)
                    debugPrint(response)
                }
                switch response.result {
                case .success(let sceneConfigListResponse):
                    if sceneConfigListResponse.code == 1 {
                        // 返回成功，传递数据
                        completion(.success(sceneConfigListResponse.data))
                    } else {
                        // 处理接口返回的失败情况
                        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 500))
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    // MARK: 添加场景
    func addScene(familyId: Int, sceneCodeList:[String], completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/scene/addScene"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        //        let parameters: [String: Any] = ["family_id": familyId, "scene_code": sceneCodeList]
        let parameters: [String: Any] = ["family_id": familyId, "scene_code": sceneCodeList.map { String($0) }.joined(separator: ",")]
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                debugPrint(response.request!)
                debugPrint(response)
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(()))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    // MARK: 场景详情
    func fetchSceneDetail(sceneCode: String, familyId: Int, completion: @escaping (Result<SceneAndGroupAndCurtainGroupList, AFError>) -> Void) {
        let url = baseURL + "/api/scene/sceneDetail"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = ["scene_code": sceneCode, "family_id": familyId]
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: SceneDetailResponse.self) { response in
                debugPrint(response.request!)
                debugPrint(response)
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(result.data))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    // MARK: 选中场景
    func selectScene(id: Int, familyId: Int, completion: @escaping (Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + "/api/scene/nowScene"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = ["id": id, "family_id": familyId]
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                debugPrint(response.request!)
                debugPrint(response)
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(result))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    // MARK: 删除场景
    func deleteScene(sceneCode: String, familyId: Int, completion: @escaping (Result<String, AFError>) -> Void) {
        let url = baseURL + "/api/scene/deleteScene"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = ["scene_code": sceneCode, "family_id": familyId]
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                debugPrint(response.request!)
                debugPrint(response)
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(result.msg))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    // MARK: 场景绑定组接口
    func joinSceneGroup(joinSceneGroupReq: JoinSceneGroupRequest, completion: @escaping (Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + "/api/scene/joinSceneGroup"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = ["scene_code": joinSceneGroupReq.scene_code, "family_id": joinSceneGroupReq.family_id,
                                         "room_id": joinSceneGroupReq.room_id, "address":joinSceneGroupReq.address,
                                         "device_type":joinSceneGroupReq.device_type, "group_id":joinSceneGroupReq.group_id,
                                         "type":joinSceneGroupReq.type]
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        print("parameters=\(parameters)")
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                debugPrint(response.request!)
                debugPrint(response)
                switch response.result {
                case .success(let result) where result.code == 1:
                    print("result.msg=\(result.msg)")
                    completion(.success(result))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    // MARK: 删除场景中的组
    func deleteSceneGroup(sceneCode: String, familyId: Int, groupAddress: String, completion: @escaping (Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + "/api/scene/deleteSceneGroup"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = ["scene_code": sceneCode, "family_id": familyId, "address": groupAddress]
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                debugPrint(response.request!)
                debugPrint(response)
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(result))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    func fetchSceneDeviceList(familyID: Int, roomId: Int, address: String, completion: @escaping (Result<[Device], AFError>) -> Void) {
        let url = baseURL + "/api/device/list"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = [
            "room_id": roomId,
            "address": address,
            "family_id": familyID
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DeviceListResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    // 返回成功，传递设备列表
                    completion(.success(result.data?.list ?? []))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    // MARK: 获取家庭成员列表
    func fetchMemberList(familyId: Int, completion: @escaping (Result<[Member], AFError>) -> Void) {
        let url = baseURL + "/api/family/memberList"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = ["family_id": familyId]
        
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: MemberListResponse.self) { response in
                if let request = response.request {
                    debugPrint(request)
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                switch response.result {
                case .success(let memberListResponse):
                    if memberListResponse.code == 1 {
                        completion(.success(memberListResponse.data))
                    } else {
                        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: memberListResponse.code))
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    // MARK: 获取用户信息
    func fetchUserInfo(completion: @escaping (Result<UserInfo, AFError>) -> Void) {
        let url = baseURL + "/api/user/getUserInfo"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        AF.request(url, method: .post, parameters: nil, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: UserInfoResponse.self) { response in
                if let request = response.request {
                    debugPrint(request)
                    debugPrint(response)
                }
                switch response.result {
                case .success(let userInfoResponse):
                    if userInfoResponse.code == 1 {
                        completion(.success(userInfoResponse.data))
                    } else {
                        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: userInfoResponse.code))
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    // MARK: - 注销用户
    func deleteUser(completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/user/deleteUser"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        AF.request(url, method: .post, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result):
                    if result.code == 1 {
                        completion(.success(()))
                    } else {
                        completion(.failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: result.code))))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - 上传图片
    func upload(file:FILE, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/common/upload"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        let parameters: [String: Any] = ["flie": file]
        
        AF.request(url, method: .post, parameters: parameters, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result):
                    if result.code == 1 {
                        completion(.success(()))
                    } else {
                        completion(.failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: result.code))))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func uploadFile(fileURL:URL?, imgData:Data?, completion: @escaping (Result<UploadedInfo?, AFError>) -> Void) {
        let url = baseURL + "/api/common/upload"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        AF.upload(
            multipartFormData: { formData in
                if fileURL != nil {
                    formData.append(fileURL!, withName: "file")
                } else if imgData != nil {
                    formData.append(imgData!, withName: "file", fileName: "image.jpg", mimeType: "image/jpeg")
                }
                
            },
            to: url,
            method: .post,
            headers: headers
        ).responseDecodable(of: UploadImageResponse.self) { response in
            if let request = response.request {
                debugPrint(request)
                debugPrint(response)
            }
            
            switch response.result {
            case .success(let result):
                if result.code == 1 {
                    completion(.success((result.data)))
                } else {
                    completion(.failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: result.code))))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    // MARK: 修改图像或昵称
    func modifyUserInfo(type: String, nickname: String, avatarUrl: String, completion: @escaping (Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + "/api/user/modifyUserInfo"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = ["type": type, "nickname": nickname, "avatar": avatarUrl ]
        
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                if let request = response.request {
                    debugPrint(request)
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                switch response.result {
                case .success(let response):
                    if response.code == 1 {
                        completion(.success(response))
                    } else {
                        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: response.code))
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: 窗帘类型列表
    func fetchCurtainTypeList(completion: @escaping (Result<[CurtainType], AFError>) -> Void) {
        let url = baseURL + "/api/curtain/curtainTypeList"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "token": token]
        
        AF.request(url, method: .post, parameters: nil, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: CurtainTypeListResponse.self) { response in
                debugPrint(response.request!)
                debugPrint(response)
                switch response.result {
                case .success(let curtainTypeListResponse): //where result.code == 1:
                    if curtainTypeListResponse.code == 1 {
                        completion(.success(curtainTypeListResponse.data!))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func addCurtainGroup(curtain_name:String, curtain_code:String, deviceType:String, familyID: Int, roomId: Int, address: String, address_number: String, completion: @escaping (Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + "/api/curtain/createGroup"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = [
            "curtain_name": curtain_name,
            "curtain_code": curtain_code,
            "device_type": deviceType,
            "room_id": roomId,
            "address": address,
            "address_number": address_number,
            "family_id": familyID
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    // 打印请求的parameters
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    // 返回成功
                    completion(.success(result))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    func fetchCurtainGroupList(familyID: Int, roomId: Int, deviceType: String, completion: @escaping (Result<[CurtainGroup], AFError>) -> Void) {
        let url = baseURL + "/api/curtain/groupList"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = [
            "room_id": roomId,
            "device_type": deviceType,
            "family_id": familyID
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: CurtainGroupListResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(result.data!))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    func addCurtainToGroup(secondType: String, mac: String, deviceVer: String, familyId: String, roomId: String, groupId: String, groupName: String, address: String, deviceType: String, deviceId: String, destination: String, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "/api/curtain/createCurtain"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = [
            "secondType": secondType,
            "mac": mac,
            "device_ver": deviceVer,
            "family_id": familyId,
            "room_id": roomId,
            "group_id": groupId,
            "group_name": groupName,
            "address": address,
            "device_type": deviceType,
            "device_id": deviceId,
            "destination": destination
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(()))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func deleteCurtainGroup(familyID: Int, roomId: Int, address: String, completion: @escaping (Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + "/api/curtain/deleteGroup"
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(AFError.explicitlyCancelled))
            return
        }
        
        let parameters: [String: Any] = [
            "room_id": roomId,
            "address": address,
            "family_id": familyID
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "token": token
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: DefaultResponse.self) { response in
                
                if let request = response.request {
                    debugPrint(request)
                    print("Request Parameters: \(parameters)")
                    debugPrint(response)
                }
                
                switch response.result {
                case .success(let result) where result.code == 1:
                    completion(.success(result))
                case .success:
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

