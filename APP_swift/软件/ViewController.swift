//
//  ViewController.swift
//  软件
//
//  Created by 朱博宇 on 2018/11/29.
//  Copyright © 2018 朱博宇. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var plateNumber: UITextField!  //车牌号
    @IBOutlet weak var name: UITextField!  //车名
    
    //停车场收费系统
    @IBOutlet weak var housetext: UITextView!  //显示存放在仓库里的车辆
    @IBOutlet weak var rodestack: UITextView!  //显示存放在路边的车辆
    @IBOutlet weak var prompt: UITextField!  //显示出车库时需要交的费用
    
    struct snode{
        var Carname : String  //车名
        var time :String      //用于计算的时间
        var time1 :String      //用于输出的时间
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
    func currentTime() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HHmm"    //计算时间
        return dateformatter.string(from: Date())
    }
    func currentTime1() ->String { 
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm:ss"
        return dateformatter.string(from: Date())
    }
    
    @IBAction func openhouse(_ sender: Any) {
        
        let tempsnode = snode(Carname: name.text!, time: currentTime(),time1:currentTime1(), number: plateNumber.text!)
        
        if carnumber < num{
            Hstack.push(tempsnode)
            carnumber += 1
            housetext.text += "\(currentTime1()) 车名:\(tempsnode.Carname) 车牌：\(tempsnode.number) \n"
        }else{
            RodeQueue.enqueue(element: tempsnode)
            carnumber += 1
            rodestack.text += "\(currentTime1()) 车名:\(tempsnode.Carname) 车牌：\(tempsnode.number) \n"
        }
        name.text = ""
        plateNumber.text = ""
    }
    //let now = today.addingTimeInterval(TimeInterval(interval))//获取当前系统时间
    
    @IBAction func clearhouse(_ sender: Any) {
        let tempsnode = snode(Carname: name.text!, time: currentTime(),time1:currentTime1(), number: plateNumber.text!)
        
        if carnumber <= num{
            if !Hstack.isEmpty{
                while(tempsnode.number != Hstack.top!.number){
                    Rstack.push(Hstack.pop()!)
                    if Hstack.isEmpty{   //如果车库为空，说明没有找到
                        prompt.text = "\(currentTime1()) 车牌号为\(tempsnode.number)的车辆未放入车库"
                        break
                    }
                }
            }else{
                prompt.text = "车库为空\n"
            }
            if !Hstack.isEmpty{  //找到了
                prompt.text = "\(currentTime1()) 车牌号为\(Hstack.top!.number)的车辆出库，请交费\(2*(Int(tempsnode.time)! - Int(Hstack.top!.time)!))元)"
                housetext.text += "\(currentTime1()) 车牌号为\(Hstack.pop()!.number)的车辆出库 \n"
                carnumber -= 1
                while(!Rstack.isEmpty){
                    Hstack.push(Rstack.pop()!)
                }
                name.text = ""
                plateNumber.text = ""
                
            }else{   //没有找到
                housetext.text += "\(currentTime1()) 车库内无车\n"
                while(!Rstack.isEmpty){//将出去的车停放回来
                    Hstack.push(Rstack.pop()!)
                }
            }
            
        }else{
            while(tempsnode.number != Hstack.top!.number){
                Rstack.push(Hstack.pop()!)
                if Hstack.isEmpty{
                    break
                }
            }
            if Hstack.isEmpty{
                prompt.text = "\(currentTime1()) 车牌号为\(tempsnode.number)的车辆未放入车库 "
                //Hstack.push(Rstack.pop()!)
            }else{
                prompt.text = "\(currentTime1()) 车牌号为\(Hstack.top!.number)的车辆出库,请交费\(2*(Int(tempsnode.time)! - Int(Hstack.top!.time)!))元"
                housetext.text += "\(currentTime1()) 车牌号为\(Hstack.pop()!.number)的车辆出库 \n"
                carnumber -= 1
                while(!Rstack.isEmpty){
                    Hstack.push(Rstack.pop()!)
                }
                
                rodestack.text += "\(currentTime1()) 车牌号为\(RodeQueue.peek()!.number)的车辆离开路边\n"
                housetext.text += "\(currentTime1()) 车牌号为\(RodeQueue.peek()!.number)的车辆从路边进入车库   \n"
                Hstack.push(RodeQueue.dequeue()!)
            }
        }
        name.text = ""
        plateNumber.text = ""
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let path = Bundle.main.path(forResource: "timg", ofType: "jpeg")
        let newImage = UIImage(contentsOfFile: path!)
        picture.image = newImage
    }


}

