// string -> @V@ hash map (open addressing, insertion-ordered `keys`).
class @N@:
    keys: [string]
    vals: [@V@]
    slots: [int]
    count: int

    make init(self):
        self.count = 0
        self.rebuild(8)

    make rebuild(self, cap: int):
        ns: [int] = []
        i = 0
        while i < cap:
            append(ns, 0)
            i += 1
        self.slots = ns
        j = 0
        while j < len(self.keys):
            self.place(self.keys[j], j)
            j += 1

    make hash(self, k: string) -> int:
        h = 5381
        i = 0
        while i < len(k):
            h = (h * 33 + char_at(k, i)) & 1073741823
            i += 1
        return h

    make place(self, k: string, idx: int):
        mask = len(self.slots) - 1
        p = self.hash(k) & mask
        while self.slots[p] != 0:
            p = (p + 1) & mask
        self.slots[p] = idx + 1

    make slot_of(self, k: string) -> int:
        mask = len(self.slots) - 1
        p = self.hash(k) & mask
        while self.slots[p] != 0:
            if self.keys[self.slots[p] - 1] == k:
                return self.slots[p] - 1
            p = (p + 1) & mask
        return -1

    make has(self, k: string) -> bool:
        return self.slot_of(k) >= 0

    make size(self) -> int:
        return self.count

    make get(self, k: string) -> @V@:
        i = self.slot_of(k)
        if i < 0:
            return @Z@
        return self.vals[i]

    make set(self, k: string, v: @V@):
        i = self.slot_of(k)
        if i >= 0:
            self.vals[i] = v
            return
        append(self.keys, k)
        append(self.vals, v)
        self.count += 1
        if self.count * 2 >= len(self.slots):
            self.rebuild(len(self.slots) * 2)
        else:
            self.place(k, self.count - 1)
