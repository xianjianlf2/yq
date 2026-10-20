The `empty` operator produces no values, not even `null`. Use it to omit values from a result stream or as a fallback with `//`.

## Emit no values
Given a sample.yml file of:
```yaml
a: cat
```
then
```bash
yq 'empty' sample.yml
```
will output
```yaml
```

## Skip missing values
Given a sample.yml file of:
```yaml
- name: cat
- {}
- name: dog
```
then
```bash
yq '[.[] | .name // empty]' sample.yml
```
will output
```yaml
- cat
- dog
```

## Omit values from an array
Running
```bash
yq --null-input '[1, empty, 2]'
```
will output
```yaml
- 1
- 2
```
