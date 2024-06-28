APP := writer

# Clear the flags from env
CPPFLAGS :=
LDFLAGS :=

# Verbose flag
ifeq ($(VERBOSE), 1)
AT =
else
AT = @
endif

ifeq ($(CROSS_COMPILE),aarch64-none-linux-gnu-)
CPPFLAGS += \
	-I /home/gerhard/compiler-toolchains/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/include/
	
# All common dependent libraries
LDFLAGS += \
	-Wl,-rpath-link=/home/gerhard/compiler-toolchains/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/lib64/ \
	-L"/home/gerhard/compiler-toolchains/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/lib64/"

else
CROSS_COMPILE :=

CPPFLAGS += \
	-I /usr/include/ \
	-I /usr/local/include/
	
# All common dependent libraries
LDFLAGS += \
	-L"/usr/lib64/" \
	-L"/usr/local/lib64/"
endif

AS             = $(AT) $(CROSS_COMPILE)as
LD             = $(AT) $(CROSS_COMPILE)ld
CC             = $(AT) $(CROSS_COMPILE)gcc
CPP            = $(AT) $(CROSS_COMPILE)g++
AR             = $(AT) $(CROSS_COMPILE)ar
NM             = $(AT) $(CROSS_COMPILE)nm
STRIP          = $(AT) $(CROSS_COMPILE)strip
OBJCOPY        = $(AT) $(CROSS_COMPILE)objcopy
OBJDUMP        = $(AT) $(CROSS_COMPILE)objdump

# All common header files
CPPFLAGS += 
	
# All common dependent libraries
LDFLAGS += 


C_SRCS := \
	writer.c

CPP_SRCS := 
CC_SRCS := 

OBJS := $(C_SRCS:.c=.o) $(CPP_SRCS:.cpp=.o) $(CC_SRCS:.cc=.o)

all: $(APP)

%.o: %.c
	@echo "Compiling: $<"
	$(CPP) -g0 -O3 $(CPPFLAGS) -c $< -o $@

%.o: %.cpp
	@echo "Compiling: $<"
	$(CPP) -g0 -O3 $(CPPFLAGS) -c $< -o $@

%.o: %.cc
	@echo "Compiling: $<"
	$(CPP) -g0 -O3 $(CPPFLAGS) -c $< -o $@

$(APP): $(OBJS)
	@echo "Linking: $@"
	$(CPP) -o $@ $(OBJS) $(CPPFLAGS) $(LDFLAGS) -lc

clean:
	$(AT)rm -rf $(APP) $(OBJS)