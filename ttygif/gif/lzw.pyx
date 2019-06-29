# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2

const int32_t MAX_STACK_SIZE = 4096
const int32_t BYTE_NUM = 256
const uint8_t BLOCK_TERMINATOR = 0x00
const uint8_t BLOCK_TERMINATOR1 = 0x8


cdef LzwEncoder(int paddedColorCount) {
    numColors = paddedColorCount
    current = new uint8_t[BLOCK_SIZE]
    memset(current, 0, BLOCK_SIZE)
    datas.emplace_back(current)
    pos = 0
    remain = 8

cdef getMinimumCodeSize(int numColors) 
    int size = 2
    while numColors > 1 << size:
        size+=1
    return size

cdef writeBits(uint32_t src, int32_t bitNum):
    while 0 < bitNum:
        if remain <= bitNum:
            current[pos] = current[pos] | (src << (8 - remain))
            src >>= remain
            bitNum -= remain
            remain = 8
            pos+=1
            if pos == BLOCK_SIZE:
                current = new uint8_t[BLOCK_SIZE]
                memset(current, 0, BLOCK_SIZE)
                datas.emplace_back(current)
                pos = 0
        else:
            current[pos] = (current[pos] << bitNum) | (((1 << bitNum) - 1) & src)
            remain -= bitNum
            bitNum = 0


int LzwEncoder::write(vector<uint8_t> &content, uint8_t minimumCodeSize) {
    content.emplace_back(BLOCK_TERMINATOR1)
    uint8_t size
    int total = 0;
    for auto block : datas:
        size = block == current ? (remain == 0 ? pos : pos + 1) : BLOCK_SIZE
        total = total + size
        content.emplace_back(size)
        for int i = 0; i < size; ++i:
            content.emplace_back(block[i])
    content.emplace_back(BLOCK_TERMINATOR)
    return total
}

void LzwEncoder::encode(uint32_t indices[], int width, int height, int size, char out[], vector<uint8_t> &content) {
    uint32_t *endPixels = indices + width * height
    uint8_t dataSize = 8
    uint32_t codeSize = dataSize + 1
    uint32_t codeMask = (1 << codeSize) - 1

    vector<uint16_t> lzwInfoHolder
    lzwInfoHolder.resize(MAX_STACK_SIZE * BYTE_NUM)
    uint16_t *lzwInfos = &lzwInfoHolder[0]
    uint32_t clearCode = 1 << dataSize
    uint32_t eolCode = clearCode + 2
    uint16_t current = *indices
    indices++

    writeBits(clearCode, codeSize)

    uint16_t *next;
    
    while endPixels > indices:
        next = &lzwInfos[current * BYTE_NUM + *indices]
        if 0 == *next || *next >= MAX_STACK_SIZE:
            writeBits(current, codeSize)
            *next = eolCode
            if eolCode < MAX_STACK_SIZE:
                eolCode+=1
            else:
                self.writeBits(clearCode, codeSize)
                eolCode = clearCode + 2
                codeSize = dataSize + 1
                codeMask = (1 << codeSize) - 1
                memset(lzwInfos, 0, MAX_STACK_SIZE * BYTE_NUM * sizeof(uint16_t))
            if codeMask < eolCode - 1 && eolCode < MAX_STACK_SIZE:
                codeSize+=1
                codeMask = (1 << codeSize) - 1
            if endPixels <= indices:
                break
            current = *indices
        else :
            current = *next
        indices+=1
    self.writeBits(current, codeSize)


    size = 2
    while numColors > 1 << size:
        size+=1
    
    ba.append()

    self.write(content,size)
