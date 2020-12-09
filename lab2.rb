require 'benchmark'
require 'digest'

def isPrimeLog(x)
	seed = Random.new_seed
	for i in 0..100
		a = (rand(seed) % (x - 2)) + 2
		if gcd(a, x) != 1
			return false
		end
		if (a.pow(x-1, x) != 1)
			return false
		end
	end
	return true
end

def getPrimeBase(bits)
	prime = rand(2**(bits-1)..2**bits-1)
	if prime % 2 == 0
		prime += 1
	end
	while (not isPrimeLog(prime))
		prime += 2
		if (prime > 2**bits-1)
			return getPrimeBase(bits)
		end
	end
	return prime
end

def gcd(a, b)
	a, b = b, a % b until b.zero?
	a.abs
end

def findRoot(m, a, b, c)
	for i in 1..m-2
		if (i.pow(a*b, m) != 1 and 
			i.pow(a*c, m) != 1 and 
			i.pow(c*b, m) != 1)
			return i
		end
	end
end

def getK(p)
	k = rand(p-3) + 2
	if gcd(k, p-1) == 1
		return k
	else
		return getK(p)
	end
end

def inverse_modulo(arg, mod)
    a, b = arg % mod, mod
    u, uu = 1, 0
    while b>0
        q = a / b
        a, b = b, a % b
        u, uu = uu, u - uu*q
		end
    if u < 0
        u += mod * ((u.abs / mod) + 1)
		end
    return u
end

def ElGamal (bitsGlobal)
	prime = 10
	i = 0
	dega = 0
	degb = 0
	degc = 0
	while (not isPrimeLog(prime) and 
		not (2**(bitsGlobal-1) <= prime and 
			prime <= 2**bitsGlobal-1)) do
		dega = 0
		degb = 0
		degc = 0

		bits = bitsGlobal
		bitsA = 2
		bitsB = bitsGlobal / 10
		while (bits > bitsGlobal/2) do
			bits -= bitsB
			degb += 1
		end

		bitsC = (bitsGlobal - bits) / 50
		if (bitsC % 2 != bitsGlobal % 2)
			bitsC -=1
		end
		while (bits > 2)
			bits -= bitsC
			degc += 1
		end
		bits += bitsC
		degc -= 1

		while (bits > 0)
			bits -= 2
			dega += 1
		end

		a = 2
		b = getPrimeBase(bitsB)
		c = getPrimeBase(bitsC)
	
		prime = a**dega * b**degb * c**degc + 1
		bits = bitsGlobal
		i += 1
	end
	if (isPrimeLog(prime) == false)
		return ElGamal(bitsGlobal)
	end
	puts "a = #{a}, deg = #{dega}"
	puts "b = #{b}, deg = #{degb}"
	puts "c = #{c}, deg = #{degc}"
	puts "#{bitsGlobal}-bits prime = #{prime}"

	g = findRoot(prime, a, b, c)
	puts "g: #{g}"

	x = getK(prime)
	puts "x: #{x}"

	y = g.pow(x, prime)
	puts "y: #{y}"

	k = getK(prime)
	puts "k: #{k}"

	r = g.pow(k, prime)
	puts "r: #{r}"

	m = (Digest::SHA1.hexdigest 'test').to_i(16) % prime
	puts "m: #{m}"

	s = ((m - x*r) * inverse_modulo(k, prime - 1)) % (prime-1)
	puts "s: #{s}"

	puts "Подпись - пара (#{r}, #{s})"

	m = (Digest::SHA1.hexdigest 'tes').to_i(16) % prime

	if ((y.pow(r, prime) * r.pow(s, prime)) % prime == g.pow(m, prime))
		puts "Подпись верна"
		return 1
	else
		puts "Ошибка подписи"
		return 0
	end
end

bitsGlobal = 1024
bench = Benchmark.measure {ElGamal(bitsGlobal)}
puts "Прошло #{bench.real} секунд"
