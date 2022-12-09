FROM python:3.9


RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install kafka-python \
    && python3 -m pip install uuid 
# Copying src code to Container
COPY twitter_data_converter.py /twitter_data_converter.py 

# Running Python Application
CMD [“python3” “twitter_data_converter.py”]