#include <mpi.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
    MPI_Init(&argc, &argv);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    const char *filename = "mpi_io_test.dat";
    MPI_File fh;
    MPI_Status st;

    int rc = MPI_File_open(MPI_COMM_WORLD, filename,
                           MPI_MODE_CREATE | MPI_MODE_WRONLY,
                           MPI_INFO_NULL, &fh);
    if (rc != MPI_SUCCESS) {
        if (rank == 0) fprintf(stderr, "Error opening %s\n", filename);
        MPI_Abort(MPI_COMM_WORLD, rc);
    }

    char buf[128];
    int n = snprintf(buf, sizeof(buf), "Hello from rank %d of %d\n", rank, size);
    MPI_Offset offset = (MPI_Offset)rank * 128;

    MPI_File_write_at(fh, offset, buf, n, MPI_CHAR, &st);
    MPI_File_sync(fh);
    MPI_File_close(&fh);

    if (rank == 0) printf("Wrote %d records to %s\n", size, filename);

    MPI_Finalize();
    return 0;
}
