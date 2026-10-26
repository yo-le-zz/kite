.PHONY: all test clean stage0 stage1
all: stage1
stage0:
	cd archive/rust-stage0 && cargo build --release --bins --examples
stage1: stage0
	cd compiler && ../archive/rust-stage0/target/release/kite build --release
test: stage1
	./build.sh test
clean:
	./build.sh clean
