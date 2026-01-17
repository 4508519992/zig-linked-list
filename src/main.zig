const std = @import("std");

const Node = struct {
    data: []const u8,
    next: ?*Node,
};

pub const LinkedList = struct {
    allocator: std.mem.Allocator,
    head: ?*Node,

    pub fn new(allocator: std.mem.Allocator) LinkedList {
        return .{
            .allocator = allocator,
            .head = null,
        };
    }

    pub fn deinit(self: *LinkedList) void {
        if (self.head == null) {
            return;
        }
        var cursor: ?*Node = self.head;
        while (cursor.?.next != null) {
            const nextPtr = cursor.?.next;
            self.allocator.destroy(cursor.?);
            cursor = nextPtr;
        }
        self.allocator.destroy(cursor.?);
    }

    pub fn append(self: *LinkedList, data: []const u8) !void {
        const node = try self.allocator.create(Node);
        node.* = Node{
            .data = data,
            .next = null,
        };
        if (self.head == null) {
            self.head = node;
            return;
        }
        var cursor: ?*Node = self.head;
        while (cursor.?.next != null) {
            cursor = cursor.?.next;
        }
        cursor.?.next = node;
    }

    pub fn delete(self: *LinkedList, data: []const u8) bool {
        if (self.head == null) return false;
        if (std.mem.eql(u8, self.head.?.data, data)) {
            var next: ?*Node = undefined;
            next = self.head.?.next;
            self.allocator.destroy(self.head.?);
            self.head = next;
            return true;
        }
        var prev: ?*Node = self.head;
        var current: ?*Node = self.head.?.next;
        while (current != null) {
            const temp: ?*Node = current.?.next;
            if (std.mem.eql(u8, current.?.data, data)) {
                self.allocator.destroy(current.?);
                prev.?.next = temp;
                return true;
            }
            prev = current;
            current = current.?.next;
        }

        return false;
    }

    pub fn print(self: *LinkedList) void {
        if (self.head == null) {
            std.debug.print("Linked list is empty\n", .{});
            return;
        }
        var cursor: ?*Node = self.head;
        while (cursor.?.next != null) {
            std.debug.print("Data: {s}, Next: {*}\n", .{ cursor.?.data, cursor.?.next });
            cursor = cursor.?.next;
        }
        if (cursor.?.next == null) {
            std.debug.print("Data: {s}, Next: {*}\n", .{ cursor.?.data, cursor.?.next });
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var ll = LinkedList.new(allocator);
    defer ll.deinit();
    try ll.append("test");
    try ll.append("test1");
    try ll.append("test2");
    try ll.append("test3");
    try ll.append("test4");
    ll.print();
    std.debug.print("After\n", .{});
    _ = ll.delete("test4");
    ll.print();
}

test "append node" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var ll = LinkedList.new(allocator);
    defer ll.deinit();

    try ll.append("test");
    try std.testing.expect(std.mem.eql(u8, ll.head.?.data, "test"));
}

test "delete first node" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var ll = LinkedList.new(allocator);
    defer ll.deinit();

    try ll.append("test");
    try std.testing.expect(ll.delete("test"));
    try std.testing.expect(ll.head == null);
}

test "delete middle node" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var ll = LinkedList.new(allocator);
    defer ll.deinit();

    try ll.append("test");
    try ll.append("test1");
    try ll.append("test2");
    try ll.append("test3");
    try ll.append("test4");

    try std.testing.expect(ll.delete("test2"));
    try std.testing.expect(std.mem.eql(u8, ll.head.?.next.?.data, "test1"));
    try std.testing.expect(std.mem.eql(u8, ll.head.?.next.?.next.?.data, "test3"));
}
