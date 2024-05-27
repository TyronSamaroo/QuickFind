
# QuickFind

QuickFind is a powerful file searching and filtering tool inspired by Neovim's Telescope plugin. It provides an easy and efficient way to search and filter files based on various criteria.

## Features

- Search all files in the current directory
- Filter files by type (e.g., Python, JavaScript, etc.)
- Search within specific directories
- Customize search depth and patterns
- Preview search results

## Installation

### From Source

To install QuickFind from the source, follow these steps:

1. Clone the repository:
   ```sh
   git clone https://github.com/your-username/QuickFind.git
   cd QuickFind
   ```

2. Move the `quickfind.sh` script to a directory in your PATH:
   ```sh
   chmod +x quickfind.sh
   mv quickfind.sh /usr/local/bin/quickfind
   ```

3. Ensure the script is executable:
   ```sh
   chmod +x /usr/local/bin/quickfind
   ```

### Using Homebrew

You can also install QuickFind using Homebrew:

1. Add the QuickFind tap:
   ```sh
   brew tap your-username/quickfind
   ```

2. Install QuickFind:
   ```sh
   brew install quickfind
   ```

## Usage

```
quickfind [options] [arguments]
```

### Examples

- Search all files in the current directory:
  ```
  quickfind
  ```

- Search Python files in the current directory:
  ```
  quickfind py
  ```

- Display help message:
  ```
  quickfind -h
  ```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with any changes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
