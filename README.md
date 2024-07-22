# Voting Contract

## Overview

This smart contract provides a simple voting system where users can add candidates, cast votes, and determine the winner based on the highest number of votes. It is designed to be deployed on a blockchain that supports Clarity smart contracts.

## Features

- **Add Candidates**: Register new candidates with a unique identifier and name.
- **Cast Votes**: Vote for existing candidates.
- **Get Candidates**: Retrieve a list of all candidates and their vote counts.
- **Get Votes**: Retrieve the number of votes for a specific candidate.
- **Get Winner**: Determine the candidate with the most votes.
- **Get Total Votes**: Retrieve the total number of votes cast across all candidates.

## Contract Functions

### `get-candidates`

**Description**: Returns a list of all candidates and their vote counts.

**Returns**: A list of tuples where each tuple contains the candidate ID, name, and vote count.

```clarity
(define-read-only (get-candidates)
  (ok (map-to-list (var-get candidates))))
```

### `get-votes (candidate u256)`

**Description**: Returns the number of votes for a specific candidate.

**Parameters**:
- `candidate`: The unique identifier of the candidate.

**Returns**: The number of votes for the specified candidate, or an error message if the candidate does not exist.

```clarity
(define-read-only (get-votes (candidate u256))
  (match (map-get (var-get candidates) candidate)
    ((some (tuple _ votes)) (ok votes))
    (none (err "Candidate not found"))))
```

### `add-candidate (candidate u256) (name string)`

**Description**: Adds a new candidate to the system. The candidate must have a unique identifier.

**Parameters**:
- `candidate`: The unique identifier for the new candidate.
- `name`: The name of the new candidate.

**Returns**: A success message if the candidate was added, or an error message if the candidate already exists.

```clarity
(define-private (add-candidate (candidate u256) (name string))
  (if (map-contains? (var-get candidates) candidate)
    (err "Candidate already exists")
    (begin
      (map-set candidates candidate (tuple name 0))
      (ok "Candidate added"))))
```

### `cast-vote (candidate u256)`

**Description**: Casts a vote for a specific candidate.

**Parameters**:
- `candidate`: The unique identifier of the candidate to vote for.

**Returns**: A success message if the vote was cast, or an error message if the candidate does not exist.

```clarity
(define-private (cast-vote (candidate u256))
  (match (map-get (var-get candidates) candidate)
    ((some (tuple name votes))
      (map-set candidates candidate (tuple name (+ votes 1)))
      (ok "Vote cast"))
    (none (err "Candidate not found"))))
```

### `get-winner`

**Description**: Determines the candidate with the highest number of votes.

**Returns**: The ID of the candidate with the most votes, or an error message if no candidates are found.

```clarity
(define-read-only (get-winner)
  (let ((winner (reduce-map (var-get candidates) (tuple u256 0) (lambda (k v acc)
    (if (> (tuple-get v 1) (tuple-get acc 1))
      (tuple k (tuple-get v 1))
      acc)))))
    (match winner
      ((tuple id _)) (ok id)
      _ (err "No candidates found"))))
```

### `get-total-votes`

**Description**: Returns the total number of votes cast across all candidates.

**Returns**: The total number of votes.

```clarity
(define-read-only (get-total-votes)
  (let ((total (reduce-map (var-get candidates) 0 (lambda (k v acc)
    (+ acc (tuple-get v 1))))))
    (ok total)))
```

## Usage

1. **Deploy the Contract**: Deploy the smart contract to the blockchain platform of your choice that supports Clarity.

2. **Add Candidates**: Use the `add-candidate` function to add new candidates with unique IDs and names.

3. **Cast Votes**: Use the `cast-vote` function to vote for candidates using their unique IDs.

4. **Retrieve Information**: Use `get-candidates`, `get-votes`, `get-winner`, and `get-total-votes` functions to retrieve information about candidates, vote counts, and overall voting statistics.

## License

This project is licensed under the MIT License.