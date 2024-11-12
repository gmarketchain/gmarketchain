# Магазин цифровых товаров для онлайн игр

# Содержит 3 смарт-контракта:
- контракт, которым владеет игра (erc721) (инвентарь)
- контракт эквивалента стоимости (erc20) (баланс)
- контракт лотов

# Интерфейсы контрактов

## Контракт игрового инвентаря

- Наследует erc721
- Позволяет изменять для предметов метаданные (название, описание, ссылку на изображение)?

## Контракт баланса

- Наследует erc20

## Контракт лотов

- cоздать_лот([(контракт_игрового_инвентаря, идентификатор_предмета, цена_продажи),..]) -> идентификатор_лота
- отменить_лот(идентификатор_лота) -> bool
- получить_список_лотов(фильтрация по играм?) -> [(идентификатор_лота, контракт_игрового_инвентаря, идентификатор_предмета, цена_продажи),...]
- купить_лот(идентификатор_лота) -> bool

# Use case

- Добавить новый смарт-контракт инвентаря в контракт лотов
- Создать лот
- Отменить лот
- Купить лот
- Эмитировать предмет в инвентарь
- Эмитировать сумму на баланс

# Описание работы методов контрактов

## Контракт лотов

### создать_лот([(контракт_игрового_инвентаря, идентификатор_предмета, цена_продажи),...]) -> идентификатор_лота

...

### отменить_лот(идентификатор_лота) -> bool

...

### получить_список_лотов(фильтрация по играм?) -> [(идентификатор_лота, контракт_игрового_инвентаря, идентификатор_предмета, цена_продажи),...]

...

### купить_лот(идентификатор_лота) -> bool

...
