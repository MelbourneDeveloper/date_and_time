flutter test --update-goldens --coverage --fail-fast

lcov  ./coverage --output-file ./coverage/lcov.info --capture --directory

# Generate HTML report
genhtml coverage/lcov.info --output-directory coverage/html