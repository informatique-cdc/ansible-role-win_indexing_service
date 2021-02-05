# win_indexing_service - Enable or disable Search Indexing

## Synopsis

* This Ansible module ensures that volume indexing is enabled or not.

## Parameters

| Parameter     | Choices/<font color="blue">Defaults</font> | Comments |
| ------------- | ---------|--------- |
|__drive_letter__<br><font color="purple">string</font> / <font color="red">required</font> |  | The drive letter assigned to a volume. |
|__state__<br><font color="purple">string</font> | __Choices__: <ul><li>absent</li><li><font color="blue">__present &#x2190;__</font></li></ul> | When `state=present` will ensure the indexing is enabled.<br>When `state=absent` will ensure the indexing is not running. |

## Examples

```yaml
---
- name: test the win_indexing_service module
  hosts: all
  gather_facts: false

  tasks:

    - name: Ensure the indexing is not running
      win_indexing_service:
        drive_letter: D
        state: absent

    - name: Ensure the indexing is enabled
      win_indexing_service:
        drive_letter: D
        state: present

```

## Authors

* Stéphane Bilqué (@sbilque) Informatique CDC

## License

This project is licensed under the Apache 2.0 License.

See [LICENSE](LICENSE) to see the full text.
