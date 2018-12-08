//
//  ViewController.swift
//  软件
//
//  Created by 朱博宇 on 2018/11/29.
//  Copyright © 2018 朱博宇. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var plateNumber: UITextField!  //车牌号
    @IBOutlet weak var name: UITextField!  //车名
    @IBOutlet weak var time: UITextField!   //停放或者出库的时间
    //停车场收费系统
    @IBOutlet weak var housetext: UITextView!  //显示存放在仓库里的车辆
    @IBOutlet weak var rodestack: UITextView!  //显示存放在路边的车辆
    @IBOutlet weak var prompt: UITextField!  //显示出车库时需要交的费用
    
    struct snode{
        var Carname : String  //车名
        var time :Int = 0
        var number : String   //车牌号
    }
    
    public struct Stack<snode>{    //创建堆栈，模拟车库
        fileprivate var array = [snode]()
        public var isEmpty: Bool {
            return array.isEmpty
        }
        public var count: Int {
            return array.count
        }
        public mutating func push(_ element: snode) {
            array.append(element)
        }
        public mutating func pop() -> snode? {
            return array.popLast()
        }
        public var top: snode? {
            return array.last
        }
    }
    
    var Rstack = Stack<snode>()  //路旁堆栈
    var Hstack = Stack<snode>()  //车库内堆栈
    var RodeQueue = Queue<snode>()  //路旁堆栈
    
    
    public struct Queue<snode> {  //路边等待的车辆放在队列
        
        // 数组用来存储数据元素
        fileprivate var data = [snode]()
        
        // 构造方法，用于构建一个空的队列
        public init() {}
        
        // 构造方法，用于从序列中创建队列
        public init<S: Sequence>(_ elements: S) where
            S.Iterator.Element == snode {
                data.append(contentsOf: elements)
        }
        
        // 将类型为T的数据元素添加到队列的末尾
        public mutating func enqueue(element: snode) {
            data.append(element)
        }
        
        // 移除并返回队列中第一个元素
        // 如果队列不为空，则返回队列中第一个类型为T的元素；否则，返回nil。
        public mutating func dequeue() -> snode? {
            return data.removeFirst()
        }
        
        // 返回队列中的第一个元素，但是这个元素不会从队列中删除
        // 如果队列不为空，则返回队列中第一个类型为T的元素；否则，返回nil。
        public func peek() -> snode? {
            return data.first
        }
        
        
        // 清空队列中的数据元素
        public mutating func clear() {
            data.removeAll()
        }
        
        
        // 返回队列中数据元素的个数
        public var count: Int {
            return data.count
        }
        
        // 返回或者设置队列的存储空间
        public var capacity: Int {
            get {
                return data.capacity
            }
            set {
                data.reserveCapacity(newValue)
            }
        }
        // 检查队列是否已满
        // 如果队列已满，则返回true；否则，返回false
        public func isFull() -> Bool {
            return count == data.capacity
        }
        
        // 检查队列是否为空
        // 如果队列为空，则返回true；否则，返回false
        public func isEmpty() -> Bool {
            return data.isEmpty
        }
    }
    var num = 0  //记录车库存放车辆数
    var carnumber = 0 //记录实时车辆数
    @IBAction func numberOK(_ sender: Any) {
        num = Int(number.text!)!
    }
    
    //var tempsnode : snode //声明临时结构体
    
    
    @IBAction func openhouse(_ sender: Any) {
        
        let tempsnode = snode(Carname: name.text!, time: Int(time.text!)!, number: plateNumber.text!)
        
        if carnumber < num{
            Hstack.push(tempsnode)
            carnumber += 1
            housetext.text += "车名:\(tempsnode.Carname) 车牌：\(tempsnode.number) 进库时间 ： \(tempsnode.time)\n"
        }else{
            RodeQueue.enqueue(element: tempsnode)
            carnumber += 1
            rodestack.text += "车名:\(tempsnode.Carname) 车牌：\(tempsnode.number) 停留路边时间 ： \(tempsnode.time)\n"
        }
        name.text = ""
        plateNumber.text = ""
        time.text = ""
    }
    func getNowTimeStamp() ->String{
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"//设置时间格式；hh——>12小时制， HH———>24小时制
        
        //设置时区
        let timeZone = TimeZone.init(identifier: "Asia/Shanghai")
        formatter.timeZone = timeZone
        
        let dateNow = Date()//当前的时间
        //当前时间戳
        let timeStamp = String.init(format: "%ld", Int(dateNow.timeIntervalSince1970))
        return timeStamp
    }
 
    //let now = today.addingTimeInterval(TimeInterval(interval))//获取当前系统时间
    
    @IBAction func clearhouse(_ sender: Any) {
        var tempsnode = snode(Carname: name.text!, time: Int(time.text!)!, number: plateNumber.text!)
        
        if carnumber <= num{
            while(tempsnode.number != Hstack.top!.number){
                housetext.text += "车牌号为\(Hstack.top!.number)的车辆出库为车牌号为\(tempsnode.number)的车辆让道\n"
                //carnumber -= 1
                Rstack.push(Hstack.pop()!)
                if Hstack.isEmpty{
                    prompt.text = "车牌号为\(tempsnode.number)的车辆未放入车库"
                    break
                }
            }
            if !Hstack.isEmpty{
                prompt.text = "车牌号为\(Hstack.top!.number)的车辆出库，请交费\(2*(tempsnode.time - Hstack.pop()!.time))元"
                carnumber -= 1
                while(!Rstack.isEmpty){
                    Hstack.push(Rstack.pop()!)
                    //carnumber += 1
                }
                name.text = ""
                plateNumber.text = ""
                time.text = ""
            }else{
                housetext.text += "车库内无车\n"
            }
            /*if carnumber < num{
                rodestack.text = "车牌号为\(RodeQueue.peek()!.number)的车辆从路边进入车库,进库时间\(getNowTimeStamp())"
                Hstack.push(RodeQueue.dequeue()!)
            }*/
        }else{
            while(tempsnode.number != Hstack.top!.number){
                housetext.text += "车牌号为\(Hstack.top!.number)的车辆出库为车牌号为\(tempsnode.number)的车辆让道\n"
                carnumber -= 1
                Rstack.push(Hstack.pop()!)
            }
            prompt.text = "车牌号为\(Hstack.top!.number)的车辆出库，出库时间\(tempsnode.time),请交费\(2*(tempsnode.time - Hstack.pop()!.time))元"
            carnumber -= 1
            while(!Rstack.isEmpty){
                Hstack.push(Rstack.pop()!)
            }
            rodestack.text += "车牌号为\(RodeQueue.peek()!.number)的车辆离开路边,离开时间时间\(tempsnode.time)\n"
            housetext.text += "车牌号为\(RodeQueue.peek()!.number)的车辆从路边进入车库,进库时间\(tempsnode.time)\n"
            Hstack.push(RodeQueue.dequeue()!)
        }
        name.text = ""
        plateNumber.text = ""
        time.text = ""
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

