#define ServerPort 1974
#define BallIdentifierMax 0xFFFF

typedef uint16_t BallIdentifier;
typedef int16_t BallPacketValue;
typedef uint16_t BallPacketCount;
#define BallPacketValueNumber 6

typedef struct {
    BallIdentifier identifier;
    BallPacketCount count;
    BallPacketValue values[BallPacketValueNumber];
} BallPacket;
