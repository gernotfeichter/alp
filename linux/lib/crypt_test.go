package lib

import "testing"

func Test_encrypt_decrypt(t *testing.T) {
	type args struct {
		plaintext string
		key       string
	}
	tests := []struct {
		name string
		args args
		want string
	}{
		{
			name: "encrypting and subsequent decrypting with the same key should yield the original text",
			args: args{plaintext: "abcdef", key: "passwordpasswordpasswordpassword"},
			want: "abcdef",
		},
		{
			name: "encrypting and subsequent decrypting with a differnt key should not yield the original text",
			args: args{plaintext: "abcdef", key: "passwordpasswordpasswordpassword"},
			want: "fedcba",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := Decrypt(Encrypt(tt.args.plaintext, tt.args.key), tt.args.key); got != tt.want {
				t.Errorf("decrypt(encrypt()) = %v, want %v", got, tt.want)
			}
		})
	}
}
