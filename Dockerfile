# Build stage
FROM microsoft/aspnetcore-build:2 as build-env

WORKDIR /generator

# restore each project or solution more globally
COPY api/api.csproj ./api/
RUN dotnet restore api/api.csproj
COPY tests/tests.csproj ./tests/
RUN dotnet restore tests/tests.csproj

#Trace all files in the image
RUN ls -alR


# copy all src code into current working dir 
COPY . .
#...except certain files

# Tests Better integration in TeamCity
ENV TEAMCITY_PROJECT_NAME=fake
# Launch tests
RUN dotnet test tests/tests.csproj --verbosity normal

# publish
RUN dotnet publish api/api.csproj -o /publish 

# Runtime stage
FROM microsoft/aspnetcore:2
COPY --from=build-env /publish /publish
WORKDIR /publish
ENTRYPOINT [ "dotnet","api.dll" ]