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
        return;
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
        if (cursor == null) {}
        cursor.?.next = node;
        return;
    }

    pub fn print(self: *LinkedList) void {
        if (self.head == null) return;
        var cursor: ?*Node = self.head;
        while (cursor.?.next != null) {
            std.debug.print("Data: {s}, Next: {*}\n", .{ cursor.?.data, cursor.?.next });
            cursor = cursor.?.next;
        }
        if (cursor.?.next == null) {
            std.debug.print("Data: {s}, Next: {*}\n", .{ cursor.?.data, cursor.?.next });
        }
        return;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var ll = LinkedList.new(allocator);
    defer ll.deinit();
    try ll.append("test");
    try ll.append("test2");
    try ll.append("test3");
    try ll.append("test4");
    try ll.append("test5");
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
