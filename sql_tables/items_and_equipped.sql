CREATE TABLE `users_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `users_id` int NOT NULL,
  `steamID` varchar(32) NOT NULL,
  `item` text,
  `color` varchar(12),
  `skin` tinyint(8) UNSIGNED,
  `bodygroup` text,
  PRIMARY KEY (`id`),
  FOREIGN KEY(users_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `users_equipped` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `users_id` int NOT NULL,
  `steamID` varchar(32) NOT NULL,
  `item` text,
  `slot` tinyint(8) UNSIGNED,
  PRIMARY KEY (`id`),
  FOREIGN KEY(users_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;