pragma solidity 0.4.23;

import "zeppelin-solidity/contracts/math/SafeMath.sol";

/*
TZ: contract creator becomes the first superuser. Then he adds new users and superusers. Every superuser can add new users and superusers;
If user sends ether, his balance is increased. Then he can withdraw eteher from his balance;
*/


contract VulnerableOne {
    // SafeMath следует использовать для типов, в которых хранятся данные, то есть для uint256
    using SafeMath for uint256;

    struct UserInfo {
        uint256 created;
        uint256 ether_balance;
        bool exist; // Смысл переменной описан в комментарии к remove_user
    }

    mapping (address => UserInfo) public users_map;
    mapping (address => bool) is_super_user;
    modifier onlySuperUser() {
        require(is_super_user[msg.sender] == true);
        _;
    }

    event UserAdded(address new_user);

    constructor() public {
        set_super_user(msg.sender);
        add_new_user(msg.sender);
    }

    // Любой пользователь может сделать кого-угодно суперюзером: добавим modifier onlySuperUser
    function set_super_user(address _new_super_user) public onlySuperUser {
        is_super_user[_new_super_user] = true;
    }

    function pay() public payable {
        require(users_map[msg.sender].exist == true);
        users_map[msg.sender].ether_balance += msg.value;
    }

    function add_new_user(address _new_user) public onlySuperUser {
        require(users_map[_new_user].exist != true);
        users_map[_new_user] = UserInfo({ created: now, ether_balance: 0, exist: true });
    }

    // Возможно не стоит разрешать любому человеку удалять юзера: добавим modifier onlySuperUser
    function remove_user(address _remove_user) public onlySuperUser {
        // Майнер может манипулировать timestamp, например, сделать его 0, тогда его никто не сможет удалить
        // вместо того, чтобы проверять created, будем проверять переменную exist, которая равна 1 у всех добавленных адресов
        require(users_map[msg.sender].exist == true);
        delete(users_map[_remove_user]);
        // Цикл неизветсной длины потенциально может потратить весь газ
        // Заметим, что массив users_list нам не нужен, он никак не используется, избавимся от него
    }

    function withdraw() public {
        // Если вызывать внешний контракт до обнуления баланса - возможен reentrancy
        uint256 balance = users_map[msg.sender].ether_balance;
        users_map[msg.sender].ether_balance = 0;
        msg.sender.transfer(balance);
    }

    function get_user_balance(address _user) public view returns(uint256) {
        return users_map[_user].ether_balance;
    }

}