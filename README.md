ruby
====

Краткий экскурс в руби:
Основные типы данных:
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
:'symbol'
:"symbol"
:symbol
%s{symbol}
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
method 1, 2, symbol=> value
```


- Regexp
```
# литеральный синтексис создания
regexp = /test/i
# создание 
rule = "test"
modifier = Regexp::EXTENDED
regexp = Regexp.new rule, modifier # экввалент /test/x

# Сравнение
regexp =~ "test" # => 0
regexp =~ "stest" # => 1
regexp =~ "stet" # => nil
```


Организация кода:
- Константа
```
Konstanta = "Значение константы 1"
KONSTANTA = "Значение константы 2"
```
- Блок
```
block = lambda do |arg|
  arg * 2
  
  "получили #{}" 
end

block.call #=> сложили

# Еще блоки
block = ->{}
block = proc do; end
block = proc{}
```
- Метод
```
def method_name argument1, argument2
  return_value = argument1
  return_value += argument2

  return_value
end
```
- Модуль
```
module Mod
end
```
- Класс
```
class A
  def method
  end
end
a = A.new
```

Контексты:
- self - объект текущего контекста выполнения
```
self.class
```
- Класс
```
class Context
  self # => Context
end
```
- Метод
```
# методы создаются в связи с контектом определенного объекта
def current_context
  self
end

current_context == self

class Context
  def self.class_context
    self
  end
  
  def object_context
    self
  end
end

Context.class_context == Context # => true
new_object = Context.new
new_object.object_context == new_object # => true
```
- Блоки
```
#
```

Как работает сервер
===
![WebServer](http://plantuml.com/plantuml/png/HO-n3S8m44Lxfl0Sq6GL9EY00a8Vd88HwA1X02V2meeJPuNdZRXB8b5SSQVttxUBIxazbzVZORNcHIBcEj_n30IyuOjZp1Kftt0ROPuqiZeQELawd674JQSUdwsoj3EfGSz79lwDenHOWXAFILwBkZEYIWnBFcf0dKgzfQaIUPZLabbC-e1MEvKhzgUT_E87)

UseCase
===
- Как писать роуты?
```
HeloWorld\
  app\
    controllers\
    views\
  config\
    routes.rb
```

- Как писать json?

```
# app/views/any.jbuilder

json.key value # => {"key": value}

json.obj do
  json.a "A"
  json.b "B"
end # => {"obj": {"a": "A", "b": "B"}}


json.(object, :property1, :property2) # => {"property1": "val1", "property2": "val2"}
```
