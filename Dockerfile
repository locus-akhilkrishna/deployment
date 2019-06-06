FROM maralabs/internaldashboard:v1
COPY InternalDashboard /var/www/html/internaldashboard
RUN chown www-data:www-data /var/www/html/internaldashboard -R
RUN pip install -r /var/www/html/internaldashboard/requirements.txt
ENV PYTHONPATH /var/www/html/internaldashboard
ENTRYPOINT ["apache2ctl", “-D”, “FOREGROUND”]
