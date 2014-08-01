ruby
====

Краткий экскурс в руби:
Основные типы:
- String - строки
```
#все это строка 123
"123"
%Q{123}

'123'
'1' '2' '3'
%q{123}
<<STRING_BRAKET
123
STRING_BRAKET
```
- Symbol - like a String
```
:'123'
:"123"
:symbol
```
- Integer
```
#все это число 10 000
10000
10_000
0b10011100010000
0x2710
```
- Array
```
#все это массивы из трех строк
['one', 'two', 'three']
%w{one two three}
```

- Hash
```
key = "anyobject"
value = key

# пример хеша
{key => value}
{symbol: value}

# пример использования хеша как последнего аргумента в методах
method(1, 2, {symbol: value})
method(1, 2, symbol: value)
method 1, 2, symbol: value
```
