# Data Warehouse and Business Intelligence
Completed as part of a group assignment with Polly Lloyd and Stephen Quinn for module called ‘Database Warehousing & Business Intelligence’ while studying Higher Diploma in Science in Data Science in Dublin Business School. Submitted on the 1st November 2020.

### The Goal
The aim of the data warehouse was to enable Publisher Ltd to capture relevant sales process information from their databases, including both current and historical data. The data needed to be stored at a granular level to allow for analysis by title, book type, time period, store, and publishing location while maintaining efficiency and optimization.

### Solution
A data warehouse was designed using Kimball’s 4-step methodology:

- Business Process: Sales was identified as the core business process
- Grain: The finest level of granularity was set at the TitleName level.
- Facts: Key metrics included quantity sold, gross revenue, discounts, and net revenue.
- Dimensions: Data was structured around Title, Store, and Calendar dimensions.
A star schema was implemented to structure the data warehouse. SQL Server Management Studio (SSMS) 2018 and Visual Studio 2018 SSIS were used for ETL processes, including loading and transforming data from operational databases. SQL Views were created to generate reports answering key business performance questions.

### Outcomes
- Successfully captured all sales data at a granular level for comprehensive reporting.
- Enabled stakeholders to analyze revenue, sales trends, and store performance.
- Implemented ETL processes to automate data extraction and transformation.
- Designed SQL Views for streamlined reporting and business intelligence.

### Challenges Faced
- Ensuring data efficiency by capturing only relevant information.
- Maintaining historical changes within dimension tables while keeping performance optimal.
- Integrating data from multiple sources and ensuring consistency.- Defining appropriate KPIs for different stakeholders' needs.

### Skills Gained
- Data Warehousing: Understanding star schema and dimensional modeling.
- ETL Development: Using SQL Server and SSIS for data extraction, transformation, and loading.
- Business Intelligence: Generating reports and SQL Views for sales analysis.
- Stakeholder Management: Aligning data solutions with business needs.
