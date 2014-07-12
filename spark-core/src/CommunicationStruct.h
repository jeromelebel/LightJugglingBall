#define ServerPort 1974
#define BALL_IDENTIFIER_MAX 0xFFFF

typedef uint16_t BALL_IDENTIFIER;
typedef int16_t VALUE_TYPE;
typedef uint16_t TIMESTAMP_TYPE;
#define NUMBER_OF_VALUE 6

typedef struct {
    BALL_IDENTIFIER identifier;
    TIMESTAMP_TYPE timestamp;
    VALUE_TYPE values[NUMBER_OF_VALUE];
} BallPacket;
